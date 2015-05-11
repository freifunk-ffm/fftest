wififind()
{
	$IWLIST scan 2>&1|grep ESSID|grep -q  $wifi &&
	{
		echo wifi $wifi found
			exit 0
	} ||
	{
		echo wifi not found
			exit 1
	}
}
