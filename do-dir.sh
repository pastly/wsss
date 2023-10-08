echo "FILES -------------------------------------------------" >> $out
for f in $files; do
	echo $f >> $out
done

echo "DIRS -------------------------------------------------" >> $out
for f in $dirs; do
	echo $f >> $out
done
