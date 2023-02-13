#
#@if not defined YOSYSHQ_ROOT (
#    for /f %%i in ("%~dp0") do @set YOSYSHQ_ROOT=%%~fi
#)

function prompt { "[OSS] $((get-item $pwd).Name) > " }
function ports { python -c "import serial.tools.list_ports as ls; print([p.device for p in ls.comports()])" }

# set root directory
$root = 'C:\oss-cad-suite'
$env:YOSYSHQ_ROOT = $root

# set path
$env:Path += ";$root\bin;$root\lib;$root\py3bin"

# set environment variables
$env:SSL_CERT_FILE = "$root\etc\cacert.pem"
$env:PYTHON_EXECUTABLE = "$root\py3bin\python3.exe"
$env:QT_PLUGIN_PATH = "$root\lib\qt5\plugins"
$env:QT_LOGGING_RULES = $false

$env:GTK_EXE_PREFIX = $root
$env:GTK_DATA_PREFIX = $root
$env:GDK_PIXBUF_MODULEDIR = "$root\lib\gdk-pixbuf-2.0\2.10.0\loaders"
$env:GDK_PIXBUF_MODULE_FILE = "$root\lib\gdk-pixbuf-2.0\2.10.0\loaders.cache"

#@set GDK_PIXBUF_MODULEDIR=%YOSYSHQ_ROOT%lib\gdk-pixbuf-2.0\2.10.0\loaders
#@set GDK_PIXBUF_MODULE_FILE=%YOSYSHQ_ROOT%lib\gdk-pixbuf-2.0\2.10.0\loaders.cache
#@gdk-pixbuf-query-loaders.exe --update-cache

gdk-pixbuf-query-loaders.exe --update-cache

