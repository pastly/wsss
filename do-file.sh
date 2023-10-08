export PATH=""
export PATH="$coreutils/bin:$PATH"
export PATH="$xz/bin:$PATH"

cp $file_name $out
#xz $file_name --to-stdout > $out
