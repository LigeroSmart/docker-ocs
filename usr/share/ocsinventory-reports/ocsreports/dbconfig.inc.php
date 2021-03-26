<?php
define("DB_NAME", getenv('OCS_DB_NAME'));
define("SERVER_READ", getenv('OCS_DB_HOST'));
define("SERVER_WRITE", getenv('OCS_DB_HOST'));
define("SERVER_PORT", getenv('OCS_DB_PORT'));
define("COMPTE_BASE", getenv('OCS_DB_USER'));
define("PSWD_BASE", getenv('OCS_DB_PWD'));
define("ENABLE_SSL", getenv('OCS_DB_SSL_ENABLED'));
define("SSL_MODE", getenv('SSL_MODE_PREFERRED'));
define("SSL_KEY", getenv('OCS_DB_SSL_CLIENT_KEY'));
define("SSL_CERT", getenv('OCS_DB_SSL_CLIENT_CERT'));
define("CA_CERT", getenv('OCS_DB_SSL_CA_CERT'));
?>