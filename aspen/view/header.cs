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

    <?cs if:ID ?>
      <form name="logoutform" id="signoutform" action="<?cs var:BASE_URL ?>/logout" method="post" class="hideform"></form>
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
            <?cs if:ID ?>
            <ul class="nav pull-right">
              <li id="fat-menu" class="dropdown">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="icon-user icon-white"></i> <?cs var:ID ?><b class="caret"></b></a>
                <ul class="dropdown-menu">
                  <li><a href="#" id="signoutbtn">Sign out</a></li>
                </ul>
              </li>
            </ul>
            <?cs /if ?>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container">
