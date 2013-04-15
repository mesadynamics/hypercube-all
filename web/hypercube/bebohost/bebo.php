<?php

/**
 * You can use this library to make calls to the Bebo API. For instance:
 *
 * $bebo = new Bebo($api_key, $api_secret);
 * $bebo->friends_get(); // get list of friends
 * $bebo->photos_get(null, $album_id, array($pid1, $pid2)); // get photos from album
 * $bebo->photos_upload($album_id, $caption, $file_data); // upload photo
 * $bebo->friends_areFriends(array ($uid1,$uid2), array ($uid3,$uid4)); // check friends
 *
 * Documentation: http://developer.bebo.com/documentation.html
 * Remote API: http://bebo.com/AppToolApi.jsp
 * Subversion: svn co https://bebo-platform.svn.sourceforge.net/svnroot/bebo-platform bebo-platform
 * Bugs: http://developer.bebo.com/cgi-bin/bugzilla/index.cgi
 **/


class BeboAPIErrorCodes {
  const UNKNOWN = 1;
  const SERVICE_UNAVAILABLE = 2;
  const OVER_DAILY_LIMIT = 4;
  const ILLEGAL_ACCESS = 5;
  const UNKNOWN_METHOD_NAME = 100;
  const INVALID_API_KEY = 101;
  const INVALID_OR_TIMED_OUT_SESSION_KEY = 102;
  const INVALID_CALL_ID = 103;
  const INVALID_SIGNATURE = 104;
  const INVALID_MARKUP = 330;
}

class Bebo {
  public $api_key = "";
  public $api_secret = "";
  public $api_version = "1.0";
  public $session_key;
  public $params;
  public $user;
  public $friends_list;
  public $added;
  public $page_added;
  
  protected $server_address = "http://apps.bebo.com/restserver.php";
  protected $prev_call_id = 0;
  protected $debug;

  public function __construct($api_key, $api_secret, $debug=false) {
    $this->api_key = $api_key;
    $this->api_secret = $api_secret;
    $this->debug = $debug;
    $this->params = $this->clean_params($_POST);
    if (empty($this->params)) {
      $this->params = $this->clean_params($_GET);
    }
    if ($this->debug) print_r($this->params);

    if ($this->params) {
      $user = isset($this->params['user']) ? $this->params['user'] : null;
      $session_key = isset($this->params['session_key']) ? $this->params['session_key'] : null;
      $expires = isset($this->params['expires']) ? $this->params['expires'] : null;
      $this->set_user($user, $session_key, $expires);
    } else if (!empty($_COOKIE) && $cookies = $this->clean_params($_COOKIE, $this->api_key)) {
      $this->set_user($cookies['user'], $cookies['session_key']);
    }
    if (isset($this->params['added'])) {
      $this->added = $this->params['added'];
    }
    if (isset($this->params['page_added'])) {
      $this->page_added = $this->params['page_added'];
    }
    if (isset($this->params['friends'])) {
      $friends_list = preg_replace('/(\\s*,\\s*)+/', ',', $this->params['friends']);
      $this->friends_list = explode(",", $friends_list);
    }
    $this->api_client = $this;
  }

  /**
   * Iframe apps don't get the params every time, so set a cookie
   */
  public function set_user($user, $session_key, $expires=null) {
    if (!$this->in_canvas() && (!isset($_COOKIE[$this->api_key . '_user']) || $_COOKIE[$this->api_key . '_user'] != $user)) {
      $cookies = array();
      $cookies['user'] = $user;
      $cookies['session_key'] = $session_key;
      $sig = self::generate_sig($cookies, $this->api_secret);
      foreach ($cookies as $k => $v) {
        setcookie($this->api_key . '_' . $k, $v, (int)$expires);
        $_COOKIE[$this->api_key . '_' . $k] = $v;
      }
      setcookie($this->api_key, $sig, (int)$expires);
      $_COOKIE[$this->api_key] = $sig;
    }
    $this->user = $user;
    $this->session_key = $session_key;
  }

  public function set_debug($debug) {
    if (!is_bool($debug)) {
      throw new Exception();
    }
    $this->debug = $debug;
  }

  public function get_params() {
    return $this->params;
  }
  
  /**
   * This function performs a URL
   * redirect from the canvas page
   */
  public function redirect($url) {
    if ($this->in_canvas()) {
      echo '<sn:redirect url="' . $url . '"/>';
    } else if (preg_match('/^https?:\/\/([^\/]*\.)?bebo\.com(:\d+)?/i', $url)) {
      echo "<script type=\"text/javascript\">\ntop.location.href = \"$url\";\n</script>";
    } else {
      header('Location: ' . $url);
    }
    exit;
  }

  public function in_frame() {
    return $this->in_canvas() || isset($this->params['in_iframe']);
  }

  public function in_canvas() {
    return isset($this->params['in_canvas']);
  }

  public function get_loggedin_user() {
    return $this->user;
  }
  
  public function require_login($next=null) {
    if ($user = $this->get_loggedin_user()) {
      return $user;
    }
    $this->redirect($this->get_login_url($next, $this->in_frame()));
  }

  public function require_add($next=null) {
    if ($user = $this->get_loggedin_user()) {
      if ($this->params['added']) {
        return $user;
      }
    }
    $this->redirect($this->get_add_url($next));
  }
  
  public static function current_url() {
    return 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];
  }
  
  public function get_login_url($next, $canvas) {
    return self::get_bebo_url() . '/SignIn.jsp?ApiKey=' . $this->api_key . (!empty($next) ? '&next=' . urlencode($next)  : '') . '&v=' . $this->api_version . (!empty($canvas) ? '&canvas' : ''); 
  }

  public function get_add_url($next=null) {
    return self::get_bebo_url() . '/c/apps/add?ApiKey=' . $this->api_key . (!empty($next) ? '&next=' . urlencode($next)  : '');
  }

  public function get_bebo_url($subdomain='www') {
    return "http://$subdomain.bebo.com";
  }

  /**
   * Get a list of all the bands of which the current user is a fan
   */
  public function bands_get() {
    return $this->execute('bands.get', array());
  }
  
  /**
   * Get a list of all the uids of all fans of a band
   * @param int $bid : band id
   */
  public function bands_getFans($bid) {
    return $this->execute('bands.getFans', array("bid"=>$bid));
  }

  /**
   * Get a list of all the uids of all members of a band
   * @param int $bid : band id
   */
  public function bands_getMembers($bid) {
    return $this->execute('bands.getMembers', array('bid' => $bid));
  }

  /**
   * Get a list of all the uids of all members of a band
   * @param int $bid : band id
   * @param array $bids an array of band ids
   * @param array $fields an array of strings describing the band info fields desired
   */
  public function bands_getInfo($bids, $fields) {
    return $this->execute('bands.getInfo', array("bids" => $bids, "fields" => $fields));
  }
  
  /**
   * Executes a SNQL query, alias of snql.query, provided for compatibility.
   * @param string $query : the query to evaluate
   */
  public function fql_query($query) {
    return $this->execute('fql.query', array('query' => $query));
  }

  /**
   * Executes a SNQL query
   * @param string $query : the query to evaluate
   */
  public function snql_query($query) {
    return $this->execute('snql.query', array('query' => $query));
  }

  /**
   * Add an item to the current user's Ch-Ch-Changes
   * @param string $title : The content to display as the title.
   * @param string $body : The content to display as the body.
   * @param string $image_1 : The url of an image to display (max size 90x90 pixels).
   * @param string $image_1_link : The url that image_1 should link to.
   * @param string $image_2 String : The url of another image to display (max size 90x90 pixels).
   * @param string $image_2_link :The url that image_2 should link to.
   * @param string $image_3 : The url of another image to display (max size 90x90 pixels).
   * @param string $image_3_link :The url that image_3 should link to.
   * @param string $image_4 : The url of another image to display (max size 90x90 pixels).
   * @param string $image_4_link : The url that image_4 should link to.
   */
  public function feed_publishStoryToUser($title, $body,
                                          $image_1=null, $image_1_link=null,
                                          $image_2=null, $image_2_link=null,
                                          $image_3=null, $image_3_link=null,
                                          $image_4=null, $image_4_link=null) {
    return $this->execute('feed.publishStoryToUser',
      array('title' => $title,
            'body' => $body,
            'image_1' => $image_1,
            'image_1_link' => $image_1_link,
            'image_2' => $image_2,
            'image_2_link' => $image_2_link,
            'image_3' => $image_3,
            'image_3_link' => $image_3_link,
            'image_4' => $image_4,
            'image_4_link' => $image_4_link));
  }

  /**
   * Add an item to the Ch-Ch-Changes of the current user and his/her friends.
   * @param string $title : The content to display as the title.
   * @param string $body : The content to display as the body.
   * @param string $image_1 : The url of an image to display (max size 90x90 pixels).
   * @param string $image_1_link : The url that image_1 should link to.
   * @param string $image_2 String : The url of another image to display (max size 90x90 pixels).
   * @param string $image_2_link :The url that image_2 should link to.
   * @param string $image_3 : The url of another image to display (max size 90x90 pixels).
   * @param string $image_3_link :The url that image_3 should link to.
   * @param string $image_4 : The url of another image to display (max size 90x90 pixels).
   * @param string $image_4_link : The url that image_4 should link to.
   */
  public function feed_publishActionOfUser($title, $body,
                                           $image_1=null, $image_1_link=null,
                                           $image_2=null, $image_2_link=null,
                                           $image_3=null, $image_3_link=null,
                                           $image_4=null, $image_4_link=null) {
    return $this->execute('feed.publishActionOfUser',
      array('title' => $title,
            'body' => $body,
            'image_1' => $image_1,
            'image_1_link' => $image_1_link,
            'image_2' => $image_2,
            'image_2_link' => $image_2_link,
            'image_3' => $image_3,
            'image_3_link' => $image_3_link,
            'image_4' => $image_4,
            'image_4_link' => $image_4_link));
  }

  /**
   * Add an item to the Ch-Ch-Changes of the current user and his/her friends.
   * @param string $actor_id : not supported (leave blank for current user)
   * @param string $title_template : The markup template to display as the title.
   * @param string $title_data : JSON encoded array that will replace tokens in title_template
   * @param string $body_template : The  markup template to display as the body.
   * @param string $body_data : JSON encoded array that will replace tokens in body_template
   * @param string $body_general : additional body markup 
   * @param string $image_1 : The url of an image to display (max size 90x90 pixels).
   * @param string $image_1_link : The url that image_1 should link to.
   * @param string $image_2 String : The url of another image to display (max size 90x90 pixels).
   * @param string $image_2_link :The url that image_2 should link to.
   * @param string $image_3 : The url of another image to display (max size 90x90 pixels).
   * @param string $image_3_link :The url that image_3 should link to.
   * @param string $image_4 : The url of another image to display (max size 90x90 pixels).
   * @param string $image_4_link : The url that image_4 should link to.
   * @param string $target_ids : A comma-delimited list of friend IDs of the current user
   */
  public function feed_publishTemplatizedAction($actor_id, $title_template, $title_data,
                                                $body_template, $body_data, $body_general,
                                                $image_1=null, $image_1_link=null,
                                                $image_2=null, $image_2_link=null,
                                                $image_3=null, $image_3_link=null,
                                                $image_4=null, $image_4_link=null,
                                                $target_ids='') {
    return $this->execute('feed.publishTemplatizedAction',
      array('actor_id' => $actor_id,
            'title_template' => $title_template,
            'title_data' => $title_data,
            'body_template' => $body_template,
            'body_data' => $body_data,
            'body_general' => $body_general,
            'image_1' => $image_1,
            'image_1_link' => $image_1_link,
            'image_2' => $image_2,
            'image_2_link' => $image_2_link,
            'image_3' => $image_3,
            'image_3_link' => $image_3_link,
            'image_4' => $image_4,
            'image_4_link' => $image_4_link,
            'target_ids' => $target_ids));
  }
  
  /**
   * Take each pair of corresponding values from uids1 and uids2 and check to see if they are friends
   * @param array $uids1 : array of ids of length x
   * @param array $uids2 : array of ids of length x
   */
  public function friends_areFriends($uids1, $uids2) {
    return $this->execute('friends.areFriends',
        array('uids1'=>$uids1, 'uids2'=>$uids2));
  }

  /**
   * Returns the friends of the current session user.
   */
  public function friends_get() {  
    if (isset($this->friends_list)) {
      return $this->friends_list;
    }
    return $this->execute('friends.get', array());
  }

  /**
   * Get a list of the current user's friends who are also users of the current app.
   */
  public function friends_getAppUsers() {
    return $this->execute('friends.getAppUsers', array());
  }

  /**
   * Get some or all the groups that a specified member has joined.
   * @param int $uid Optional : The uid of the user to check. If ommitted, AND if gids is ommitted, the current user's uid will be used.
   * @param array $gids Optional : group ids to query
   */
  public function groups_get($uid, $gids) {
    return $this->execute('groups.get',
        array(
        'uid' => $uid,
        'gids' => $gids));
  }

  /**
   * Retrieve the member, admin, officer, and not_replied lists for the specified gid
   * @param int $gid : The gid of the group to retrieve the members of
   */
  public function groups_getMembers($gid) {
    return $this->execute('groups.getMembers',
      array('gid' => $gid));
  }

  /**
   * Retrieve the information about incoming messages of various types
   */
  public function notifications_get() {
    return $this->execute('notifications.get', array());
  }

  /**
   * Send a notification to the current user's friends or other users of the current app.
   * If an attempt to send a notification to bebo members who are not users of this app,
   * then a url for a confirmation page will be returned.
   * @param array $to_ids : list of uid values
   * @param string $notification : markup
   */
  public function notifications_send($to_ids, $notification) {
    return $this->execute('notifications.send', array('to_ids' => $to_ids, 'notification' => $notification));
  }

  /**
   * Retrieve one or more photos using one or more criteria.
   * Even though all the parameters are individually optional, at least one parameter must be provided.
   * @param int $subj_id Optional: not supported at this time
   * @param int $aid Optional: the aid of the album of the photos to retrieve
   * @param array $pids Optional: a list of pids of the photos to retrieve
   */
  public function photos_get($subj_id, $aid, $pids) {
    return $this->execute('photos.get',
      array('subj_id' => $subj_id, 'aid' => $aid, 'pids' => $pids));
  }

  /**
   * Create a photo album, returns the same result as photos.getAlbums called on the newly created album
   * @param string $name : a name for the photo album
   * @param string $location Optional : not supported at this time
   * @param String $description Optional : description for the photo album
   */
  public function photos_createAlbum($name, $location, $description) {
    return $this->execute('photos.createAlbum',
      array('name' => $name,
            'location' => $location,
            'description' => $description));
  }
  
  /**
   * Retrieve information about albums specified by the album owner or one or more album ids.
   * At least one of uid or aids MUST be provided.
   * @param int $uid Optional : the uid of the album creator
   * @param array aids Optional : the aids of the albums to retrieve 
   */
  public function photos_getAlbums($uid, $aids) {
    return $this->execute('photos.getAlbums',
      array('uid' => $uid,
            'aids' => $aids));
  }
  
  /**
   * Upload a photo
   * @param int $aid Optional : the id of the photo album into which to upload this photo
   * @param string $captioin Optional : a caption for this photo
   * @param file $data : the photo file data
   */
  public function photos_upload($aid, $caption, $file_data) {
    return $this->execute('photos_upload',
      array('aid' => $aid,
            'caption' => $caption,
            'data' => $file_data));
  }
  
  /**
   * Retrieve information from the user table for one or more members
   * @param array $uids : an array of user ids
   * @param array $fields : an array of strings describing the info fields desired
   */
  public function users_getInfo($uids, $fields) {
    return $this->execute('users.getInfo', array('uids' => $uids, 'fields' => $fields));
  }

  /**
   * Retrieve the uid of the current user
   */
  public function users_getLoggedInUser() {
    return $this->execute('users.getLoggedInUser', array());
  }


  /**
   * Test to see if this app is added to the current user's profile
   */
  public function users_isAppAdded() {
    if (isset($this->added)) {
      return $this->added;
    }
    return $this->execute('users.isAppAdded', array());
  }

  /**
   * Set the specified user or page's current SNML. Alias of profile.setSNML, provided for compatibility
   * @param string $markup : The snml to be saved
   * @param int $uid : The id of the user or page
   * @param string $profile : The snml that will appear in the profile box on the user's profile.
   * @param string $profile_action : The snml used in profile actions. Bebo does not support profile actions at this time.
   * @param string $mobile_profile : The snml used in the mobile version of the profile. This parameter is not *yet* supported by Bebo
   */
  function profile_setFBML($markup, $uid = null, $profile='', $profile_action='', $mobile_profile='') {
    return $this->execute('profile.setFBML',
                          array('markup' => $markup,
                                'uid' => $uid,
                                'profile' => $profile,
                                'profile_action' => $profile_action,
                                'mobile_profile' => $mobile_profile));
  }
  
  /**
   * Set the specified user or page's current SNML. Alias of profile.setSNML, provided for compatibility
   * @param string $markup : The snml to be saved
   * @param int $uid : The id of the user or page
   * @param string $profile : The snml that will appear in the profile box on the user's profile.
   * @param string $profile_action : The snml used in profile actions. Bebo does not support profile actions at this time.
   * @param string $mobile_profile : The snml used in the mobile version of the profile. This parameter is not *yet* supported by Bebo
   */
  function profile_setSNML($markup, $uid = null, $profile='', $profile_action='', $mobile_profile='') {
    return $this->execute('profile.setSNML',
                          array('markup' => $markup,
                                'uid' => $uid,
                                'profile' => $profile,
                                'profile_action' => $profile_action,
                                'mobile_profile' => $mobile_profile));
  }
  
  /**
   * Retrieve the specified user's current SNML, alias of profile.getSNML provided for compatibility
   * @param int $uid Optional : The uid of the member for whom to fetch the SNML. Defaults to the current user's uid.
   */
  public function profile_getFBML($uid) {
    return $this->execute('profile.getFBML', array('uid' => $uid));
  }

  /**
   * Retrieve the specified user's current SNML
   * @param int $uid Optional : The uid of the member for whom to fetch the SNML. Defaults to the current user's uid.
   */
  public function profile_getSNML($uid) {
    return $this->execute('profile.getSNML', array('uid' => $uid));
  }
  
  /**
   * Alias for snml.refreshImgSrc, provided for compatibility
   * @param string $url : The absolute url of the image to refresh
   */
  public function fbml_refreshImgSrc($url) {
    return $this->execute('fbml.refreshImgSrc', array('url' => $url));
  }

  /**
   * Alias for snml.refreshRefUrl, provided for compatibility
   * @param string $url : The absolute url where the content to be refreshed can be found
   */
  public function fbml_refreshRefUrl($url) {
    return $this->execute('fbml.refreshRefUrl', array('url' => $url));
  }
  
  /**
   * Alias for snml.setRefHandle, provided for compatibility
   * @param string fbml : The snml content.
   * @param string handle : The "handle" that should refer to the snml content.
   */
  public function fbml_setRefHandle($handle, $fbml) {
    return $this->execute('fbml.setRefHandle', array('handle' => $handle, 'fbml' => $fbml));
  } 
  
  /**
   * Bebo makes copies of any images referenced in your content.
   * Calling this method will force bebo to take a fresh copy of the source image from the app server.
   * Use this if you have changed an you are hosting and want the updated version to be visible to your app users.
   * @param string $url : The absolute url of the image to refresh
   */
  public function snml_refreshImgSrc($url) {
    return $this->execute('snml.refreshImgSrc', array('url' => $url));
  }

  /**
   * Bebo makes copies of any content referenced tags in your content.
   * Calling this method will force bebo to take a fresh copy of the content.
   * Use this if the content that bebo has cached has changed and you and want the updated version to be visible to your app users.
   * @param string $url : The absolute url where the content to be refreshed can be found
   */
  public function snml_refreshRefUrl($url) {
    return $this->execute('snml.refreshRefUrl', array('url' => $url));
  }
  
  /**
   * Associates a block of snml content with a "handle" that can be used in the  tag
   * @param string snml : The snml content.
   * @param string handle : The "handle" that should refer to the snml content.
   */
  public function snml_setRefHandle($handle, $snml) {
    return $this->execute('snml.setRefHandle', array('handle' => $handle, 'fbml' => $snml));
  } 
  
  /**
   * Returns cookies that will be proxied for the given user
   * @param int $uid : user whose cookies should be retrieved
   * @param string $name Optional : name of the cookie to be retrieved. if null, returns all cookies for the given user
   */
  public function data_getCookies($uid, $name) {
    return $this->execute('data.getCookies',
        array(
        'uid' => $uid,
        'name' => $name));
  }

  /**
   * Sets a cookie for a given user. Returns true of the action was successful.
   * @param int $uid : user to associate with the cookie
   * @param string $name : name of the cookie
   * @param string $value Optional
   * @param int $expires Optional
   * @param string $path Optional
   */
  public function data_setCookie($uid, $name, $value, $expires, $path) {
    return $this->execute('data.setCookie',
        array(
        'uid' => $uid,
        'name' => $name,
        'value' => $value,
        'expires' => $expires,
        'path' => $path));
  }

  /**
   * Returns a map for the requested property names to values
   * @param array $properties : list of property names to get
   */
  public function admin_getAppProperties($properties) {
    return json_decode($this->execute('admin.getAppProperties', array('properties' => json_encode($properties))),true);
  }

  /**
   * Sets the poperties for an app.
   * Returns true on success.
   *
   * @param array $properties : a map ofproperty names to values
   */
  public function admin_setAppProperties($properties) {
    return $this->execute('admin.setAppProperties', array('properties' => json_encode($properties)));
  }  
  
  public function auth_createToken(){
  	return $this->execute('auth.createToken',array());
  }
  
  public function auth_getSession($token){
  	return $this->execute('auth.getSession', array('auth_token'=>$token));
  }
  
  /**
   * Returns information about the requested profile pages or of the
   * profile pages for which the given user is a fan of.
   * @param array $page_ids : an array of profile page ids
   * @param array $fields : an array of fields to return
   * @param int $uid Optional : return only profile pages that this user is a fan of
   * @param string type : returns only profile pages of the given type
   */
  public function pages_getInfo($page_ids, $fields, $uid, $type) {
    return $this->execute('pages.getInfo', array('page_ids' => $page_ids, 'fields' => $fields, 'uid' => $uid, 'type' => $type));
  }

  /**
   * Returns true if logged in user is an admin of the given profile page
   * @param int $page_id : profile page id
   */
  public function pages_isAdmin($page_id) {
    return $this->execute('pages.isAdmin', array('page_id' => $page_id));
  }

  /**
   * Returns whether or not the profile page, whose "sn_page_id"/"fb_page_id" query parameter was passed
   * through the canvas url, has the app installed
   */
  public function pages_isAppAdded() {
    if (isset($this->page_added)) {
      return $this->page_added;
    }
    return $this->execute('pages.isAppAdded', array());
  }

  /**
   * Returns true if the given user is a fan of the given page
   * @param int $page_id : profile page id
   * @param int $uid : id of the user. defaults to the logged in user if empty.
   */
  public function pages_isFan($page_id, $uid) {
    return $this->execute('pages.isFan', array('page_id' => $page_id, 'uid' => $uid));
  }

  
  public function __call($function, $args) {
    return $this->execute(str_replace("_", ".", $function), isset($args[0]) ? $args[0] : array());
  }
  
  protected function execute($method, $params) {
    if (!is_array($params)) {
      throw new Exception();
    }

    $params['method'] = $method;
    $params['api_key'] = $this->api_key;
    $params['session_key'] = $this->session_key;
    $params['v'] = "1.0";
    $params['call_id'] = max(microtime(true), $this->prev_call_id + 0.001);
    $this->prev_call_id = $params['call_id'];

    //flatten array
    foreach ($params as $k => $v) {
      if (is_array($v)) {
        $params[$k] = implode(',', $v);
      }
    }

    $params['sig'] = self::generate_sig($params, $this->api_secret);
    $post_string = http_build_query($params);

    if ($method == 'photos.upload') {
      $boundary = md5(time());
      $content = array();
      $content[] = '--' . $boundary;
      foreach ($params as $key => $val) {
        $content[] = 'Content-Disposition: form-data; name="' . $key . '"' . "\r\n\r\n" .
                  $val . "\r\n--" . $boundary;
      }

      $filename = $params['filename'];

      preg_match('/.*?\.([a-zA-Z]+)/', basename($filename), $match);
      $type = strtolower($match[1]);
      if ($type == 'jpg') {
        $type = 'jpeg';
      }

      $content[] = 'Content-Disposition: form-data; name="data"; filename="' . $filename . '"' . "\r\n" .
                   'Content-Type: image/' . $type . "\r\n\r\n" .
                   file_get_contents($filename) . "\r\n--" . $boundary;
      $content[] = array_pop($content) . '--';


      $content = implode("\r\n", $content);
      $header = 'User-Agent: Bebo PHP5 Client 0.9 '.phpversion()."\r\n".
                'Content-Type: multipart/form-data; boundary='.$boundary."\r\n".
                'MIME-version: 1.0'."\r\n".
                'Content-length: '.strlen($content)."\r\n".
                'Keep-Alive: 300'."\r\n".
                'Connection: keep-alive';
    } else {
      $header = 'Content-type: application/x-www-form-urlencoded'."\r\n".
                           'User-Agent: Bebo PHP5 Client 0.9 '.phpversion()."\r\n".
                           'Content-length: '.strlen($post_string);
    }

    if (function_exists('curl_init')) {
      $ch = curl_init();
      curl_setopt($ch, CURLOPT_URL, $this->server_address);
      curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string);
      curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
      curl_setopt($ch, CURLOPT_USERAGENT, 'Bebo PHP5 Client 0.9 ' . phpversion());
      $result = curl_exec($ch);
      curl_close($ch);
   
    } else {
   
      $context =
        array('http' =>
          array ('method' => 'POST',
                'header' => 'Content-type: application/x-www-form-urlencoded'."\r\n".
                           'User-Agent: Bebo PHP5 Client 0.9 '.phpversion()."\r\n".
                           'Content-length: '.strlen($post_string),
                'content' => $post_string));
      
      $sock=fopen($this->server_address, 'r', false, stream_context_create($context));
      if ($sock) {
        $result='';
        while(!feof($sock)) {
          $result .= fgets($sock, 4096);
        }
        fclose($sock);
      }      
    }

    $sxml = simplexml_load_string($result);
    return self::sxml_to_array($sxml);
  }

  protected static function sxml_to_array($sxml) {
    $arr = array();
    if ($sxml) {
      foreach ($sxml as $k => $v) {
        if ($sxml['list']) {
          $arr[] = self::sxml_to_array($v);
        } else {
          $arr[$k] = self::sxml_to_array($v);
        }
      }
    }
    if (sizeof($arr) > 0) {
      return $arr;
    } else {
      return trim((string)$sxml);
    }
  }

  public static function generate_sig($params, $secret) {
    ksort($params);
    $plaintext = '';
    foreach ($params as $k => $v) {
      if ($k != '') {
        if (isset($v)) {
          $plaintext .= "$k=$v";
        }
      }
    }

    return md5($plaintext . $secret);
  }

  protected function validate_params($params, $expected) {
    return self::generate_sig($params, $this->api_secret) == $expected;
  }

  public function clean_params($params, $namespace='fb_sig') {
    $prefix = $namespace . '_';
    $bebo_params = array();
    foreach ($params as $k => $v) {
      if (strpos($k, $prefix) === 0) {
        $bebo_params[substr($k, strlen($prefix))] = urldecode($v);
      }
    }
    if (!isset($params[$namespace]) || !$this->validate_params($bebo_params, $params[$namespace])) {
      return array();
    }
    return $bebo_params;
  }
}
?>
