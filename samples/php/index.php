<?
/* Configure these three variables for your application */
$api_base_url    = "https://suppliertest.youdo.co.nz/external_api";
$consumer_key    = 'api key goes here';
$consumer_secret = 'api secret goes here';

$request_token_url = "$api_base_url/oauth/request_token";
$authorize_url     = "$api_base_url/oauth/authorize";
$access_token_url  = "$api_base_url/oauth/access_token";
$api_url           = "$api_base_url/v1";

$callback_url = "http://$_SERVER[HTTP_HOST]$_SERVER[SCRIPT_NAME]";

session_start();

if (isset($_GET['clear'])) {
  session_destroy();
  print "logged out";
  exit();
}

function output_response($response) {
  $data = json_decode($response);
  print '<pre>';
  print_r($data);
  print '</pre>';
  return $data;
}

// In state=1 the next request should include an oauth_token.
// If it doesn't go back to 0
if (!isset($_GET['oauth_token']) && $_SESSION['state']==1) $_SESSION['state'] = 0;

try {
	$oauth = new OAuth($consumer_key, $consumer_secret, OAUTH_SIG_METHOD_HMACSHA1, OAUTH_AUTH_TYPE_URI);
	$oauth->enableDebug();
	if (!isset($_GET['oauth_token']) && !$_SESSION['state']) {
		$request_token_info = $oauth->getRequestToken($request_token_url, $callback_url);
		$_SESSION['secret'] = $request_token_info['oauth_token_secret'];
		$_SESSION['state'] = 1;
		header("Location: $authorize_url?oauth_token=" . urlencode($request_token_info['oauth_token']));
		exit;
	} else if ($_SESSION['state'] == 1) {
		$oauth->setToken($_GET['oauth_token'], $_SESSION['secret']);
		$access_token_info = $oauth->getAccessToken($access_token_url);
		$_SESSION['state'] = 2;
		$_SESSION['token'] = $access_token_info['oauth_token'];
		$_SESSION['secret'] = $access_token_info['oauth_token_secret'];
	} 
	$oauth->setToken($_SESSION['token'], $_SESSION['secret']);

	if ($_REQUEST['action'] == "topup") {
    	$oauth->fetch("$api_url/top_up.js?offer_key=".urlencode($_REQUEST['key'])."&icp_number=".urlencode($_REQUEST['icp_number']), "", OAUTH_HTTP_METHOD_POST);
	    $topup = json_decode($oauth->getLastResponse())->result;
		if ($topup->result == "success")
			print 'Successfully purchased.';
		else
			print "Error purchasing: $topup->message";
		print ' <a href="?">back</a>';
		exit();
	}

	if ($_REQUEST['action'] == "readings") {
		$url = "$api_url/meter_readings.js?icp_number=".urlencode($_REQUEST['icp_number']);
		foreach ($_REQUEST['readings'] as $k=>$v) {
			$url .= "&readings[".urlencode($k)."]=".urlencode($v);
		}

    	$oauth->fetch($url, "", OAUTH_HTTP_METHOD_POST);
	    $topup = json_decode($oauth->getLastResponse())->result;
		if ($topup->result == "success")
			print 'Successfully updated.';
		else
			print "Error updating: $topup->message";
		print ' <a href="?">back</a>';
		exit();
	}

  
	$oauth->fetch("$api_url/customer.js");
	$customer = json_decode($oauth->getLastResponse())->result;
	print "<h1>Powershop account for " . htmlspecialchars("$customer->first_name $customer->last_name ($customer->email)") . "</h1>";

	print '<p><a href="?clear=1">logout</a></p>';

	foreach ($customer->properties as $property) {
		$icp_number = $property->icp_number;

		print "<h2>ICP $icp_number</h2>";

		$address = $property->address;
		print "<p>" . htmlspecialchars("$address->flat_number/$address->street_number $address->street_name, $address->suburb, $address->district, $address->region") . "</p>";

		print "<h3>Unit balance</h3>";
		print "<p>Current balance is $property->unit_balance units - consuming $property->daily_consumption units per day</p>";

		print "<h3>Registers</h3>";
		print '<table><tr><th>Number</th><th>Last Read At</th><th>Last Read Value</th><th>Estimated Read</th></tr>';
		foreach ($property->registers as $register) {
			print "<tr><td>$register->register_number</td><td>$register->last_reading_at</td><td>$register->last_reading_value</td><td>$register->estimated_reading_value</td></tr>";
		}
		print '</table>';

		print '<h3>Products available</h3>';
		$oauth->fetch("$api_url/products.js?icp_number=$icp_number");
		$products = json_decode($oauth->getLastResponse());
		print '<table><tr><th>Product</th><th>Type</th><th>Price Per Unit</th></tr>';
		foreach ($products->result as $product) {
			print "<tr><td>" . htmlspecialchars($product->name) . "</td><td>$product->type</td><td align='right'>$product->price_per_unit</td></tr>";
		}
		print '</table>';

		$start_date = strftime("%Y-%m-%d", time() - 90*24*60*60);
		$end_date = strftime("%Y-%m-%d");

		print '<h3>Register readings</h3>';
		$oauth->fetch("$api_url/meter_readings.js?icp_number=$icp_number&start_date=$start_date&end_date=$end_date");
		$readings = json_decode($oauth->getLastResponse());
		print '<table><tr><th>Register</th><th>Date</th><th>Type</th><th>Value</th></tr>';
		foreach ($readings->result as $reading) {
			print "<tr><td>$reading->register_number</td><td>$reading->read_at</td><td>$reading->reading_type</td><td>$reading->reading_value</td></tr>";
		}
		print '</table>';
		?>

		<h3>Enter readings</h3>
		<form action="" method="post">
			<input type="hidden" name="action" value="readings"/>
			<input type="hidden" name="icp_number" value="<?= $icp_number ?>"/>
			<? foreach ($property->registers as $register): ?>
				<div>
				Register <?= $register->register_number ?>: <input type="text" name="readings[<?=$register->register_number?>]"/> (<?= $register->dials ?> digits)
				</div>
			<? endforeach; ?>
			<input type="submit" value="Submit Readings"/>
		</form>
		
		<?
		print '<h3>Fast Top-Up</h3>';
		if ($property->unit_balance >= 0) {
			print "<p>Your account is not in arrears.</p>";
		} else {
			$oauth->fetch("$api_url/top_up.js?icp_number=$icp_number");
			$topup = json_decode($oauth->getLastResponse())->result;
			print "<p>Buy ".(-$topup->unit_balance)." units of \"".htmlspecialchars($topup->product_name)."\" for $".sprintf("%.02f", $topup->total_price)."? <a href=\"?action=topup&amp;icp_number=$icp_number&amp;key=$topup->offer_key\">Buy Now</a></p>";
		}
	}


  if (false) {
    print '<pre>';
    print_r($data);
    print '</pre>';
  }

} catch (OAuthException $E) {
	print_r($E);
}
?>
