<?php
/*	
 * PHP Script to send Xtify 2.x messages with Curl
 * Please read the associated README file on how to use this script
 * 
 * @AndersRetteras, march 2012
 * 
 */
class pushNotification
{
    public $pushMessage;
	
	// constructor
    public function __construct($title,$msg,$recipients) {
    	$this->pushMessage = new pushMessage($title,$msg,$recipients);
    }
	
	public function getAsJSON(){
		$encoded = json_encode($this->pushMessage);
		
		return $encoded;
	}
	
	public function sendMessage(){
		$content = $this->getAsJSON();
		
		$url = 'http://api.xtify.com/2.0/push';
		$ch = curl_init();
		
		curl_setopt($ch, CURLOPT_URL, $url);
		
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, "$content");
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json")); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		
		$output = curl_exec($ch);
		curl_close($ch);
		
		return $output;
	}
}

class pushMessage 
{
	public $apiKey="";	
	public $appKey="";
	public $xids = array();
	public $hasTags = array();
	public $notTags = array();
	public $sendAll = false;
	public $content;
	
	public function __construct($title,$msg,$recipients){
		$this->apiKey = "ADD_YOUR_APIKEY_HERE";
		$this->appKey = "ADD_YOUR_APPKEY_HERE";
		
		foreach ($recipients as &$recipient) {
    		array_push($this->xids, $recipient);
		}
	
		$this->content = new content($title,$msg);
	}
}
class content {
	public $subject="";
	public $message="";
	public $action;
	public $rich;
	public $payload;
	public $sound="";
	public $badge="";
	public $actionCategories="";
	//public $groupId="";
	
	public function __construct($title,$msg){
		$this->subject = $title;
		$this->message = $msg;
		$this->action = new action();
	}
}
class action {
	public $type="";	//URL|RICH|CUSTOM|DEFAULT|NONE
	public $data="";	//url|intent|...
	public $label="";
	
	public function __construct(){
		$this->type="DEFAULT"; 
	}		
}
class rich {
	public $subject="";
	public $message="";
	public $action;

	public function __construct(){
		$this->action = new action();
	}	
}
?>