# Set paths and links:
js_package_path="js-package/build/dist/js/productionExecutable/"
extension_path="python-extension/build/bin/native/releaseStatic/"

# Get Python bin and include directories for the extension build:  
py_bin_path=$($PYTHON -c "from sysconfig import get_paths as gp; print(gp()['scripts'])")
py_include_path=$($PYTHON -c "from sysconfig import get_paths as gp; print(gp()['include'])")
py_architecture=$($PYTHON -c "import platform; print(platform.machine())")

# # Configuring ImageMagick fonts for build process
# im_config_path="$SRC_DIR/im_config"
# mkdir -p $im_config_path

# fonts_path=$(find "$PREFIX/fonts" -name "*.ttf" | head -n 1)

# if [ -z $fonts_path ]; then
#    echo "ERROR: No fonts found in $PREFIX/fonts. Build will fail."
# elif [ -n $fonts_path ]; then
#    echo "Found fonts for build: ${fonts_path}"

#    cat <<EOF > "${im_config_path}/type.xml"
# <?xml version="1.0" encoding="UTF-8"?>
# <typemap>
#   <type name="Arial" fullname="Arial" family="Arial" weight="400" style="normal" stretch="normal" format="truetype" glyphs="${fonts_path}"/>
# <type name="Helvetica" fullname="Helvetica" family="Helvetica" weight="400" style="normal" stretch="normal" format="truetype" glyphs="${fonts_path}"/>
# </typemap>
# EOF

#    export MAGICK_CONFIGURE_PATH="${im_config_path}:${MAGICK_CONFIGURE_PATH}"
# else
#    echo "WARNING: Could not configure fonts. Gradle might fail."
# fi

echo "DEBUG: $(ls -l $IMAGICK_LIB_PATH)"

echo "DEBUG: $(which magick \|\| which convert)"
echo "DEBUG: $(magick -version)"
echo "DEBUG: =================================="
export MAGICK_DEBUG=Font 
magick -list font | head -50
#otool -L $(which magick) | grep -i fontconfig
echo "DEBUG: =================================="
fc-list | head
echo "DEBUG: =================================="

if [ ! -f $extension_path ]; then
   # Runs extension build:
   ./gradlew python-extension:build -Pbuild_release=true -Ppython.bin_path=${py_bin_path} -Ppython.include_path=${py_include_path} -Penable_python_package=true -Parchitecture=${py_architecture}
fi

if [ ! -f $js_package_path ]; then
   # Includes JS package to the build:
   ./gradlew js-package:jsBrowserProductionWebpack -Pbuild_release=true -Penable_python_package=false -Parchitecture=${py_architecture}
fi

$PYTHON -m pip install $SRC_DIR/python-package -vv --no-deps --no-build-isolation
