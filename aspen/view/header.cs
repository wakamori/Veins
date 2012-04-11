<!doctype html>
<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

	<title><?cs var:Title ?></title>
	<meta name="description" content="<?cs var:Description ?>">
	<meta name="author" content="">

	<meta name="viewport" content="width=device-width">

	<link rel="stylesheet/less" href="<?cs var:STATIC_URL ?>/less/style.less">
	<script src="<?cs var:STATIC_URL ?>/js/libs/less-1.3.0.min.js"></script>
	
	<!-- Use SimpLESS (Win/Linux/Mac) or LESS.app (Mac) to compile your .less files
	to style.css, and replace the 2 lines above by this one:

	<link rel="stylesheet/less" href="<?cs var:STATIC_URL ?>/less/style.css">
	 -->

	<script src="<?cs var:STATIC_URL ?>/js/libs/modernizr-2.5.3-respond-1.1.0.min.js"></script>
</head>
<body>
<!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->
<!-- JavaScript SDK from facebook -->
  <div id="fb-root"></div>
    <script>(function(d, s, id) {
      var js, fjs = d.getElementsByTagName(s)[0];
      if (d.getElementById(id)) return;
      js = d.createElement(s); js.id = id;
      js.src = "//connect.facebook.net/ja_JP/all.js#xfbml=1";
      fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));</script>
  </div>
    <?cs if:ID ?>
    <?cs else ?>
      <div class="modal fade" id="sign-in">
        <div class="modal-header">
          <a class="close" data-dismiss="modal">&times;</a>
          <h3>Sign in form</h3>
        </div>
        <div class="modal-body">
          <form class="well" id="signinform">
            <input id="input-username" name="username" type="text" class="input-medium" placeholder="Username"<?cs if:Remember == "on" ?> value="<?cs var:Username ?>"<?cs /if ?>>
            <input id="input-password" name="password" type="password" class="input-medium" placeholder="Password"<?cs if:Remember == "on" ?> value="<?cs var:Password ?>"<?cs /if ?>>
            <label class="checkbox">
              <input id="input-remember" type="checkbox" name="remember" value="on"<?cs if:Remember == "on" ?> checked<?cs /if ?>> Remember me
            </label>
            <a class="btn" id="signinbtn">Sign in</a>
          </form>
        </div>
      </div>
    <?cs /if ?>
    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="<?cs var:BASE_URL ?>/"><?cs var:Header.Title ?></a>
          <div class="nav-collapse">
            <ul class="nav">
              <?cs each:item = Header.Navigation ?>
              <li>
                <a href="<?cs var:BASE_URL ?><?cs var:item.URL ?>">
                  <?cs var:item.Name ?>
                </a>
              </li>
              <?cs /each ?>
            </ul>
            <form class="navbar-search" action="<?cs var:BASE_URL ?>/action/search" method="get">
              <input type="search" name="text" class="search-query" placeholder="Search">
            </form>
            <form action="<?cs var:BASE_URL ?>/action/logout" method="post" class="hideform" id="signoutform"></form>
            <ul class="nav pull-right">
              <?cs if:ID ?>
              <li id="fat-menu" class="dropdown">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="icon-user icon-white"></i> <?cs var:ID ?><b class="caret"></b></a>
                <ul class="dropdown-menu">
                  <li><a href="<?cs var:BASE_URL ?>/<?cs var:ID ?>"><i class="icon-home"></i> Home</a></li>
                  <li><a href="#" id="signoutbtn">Sign out</a></li>
                </ul>
              </li>
              <?cs else ?>
              <li>
                <a data-toggle="modal" href="#sign-in">Sign in</a>
              </li>
              <?cs /if ?>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container">
      <div id="confirmDiv"></div>
      <div id="alertbox"></div>
