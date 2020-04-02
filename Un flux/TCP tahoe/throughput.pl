

$infile=$ARGV[0];
$granularity=$ARGV[1];
$ftput=$ARGV[2];
$floss=$ARGV[3];


$sum=0;
$sum3=0;
$sum2=0;
$clock=0;

open (DATA,"<$infile")
|| die "Cannot open $infile $!";
open (DATA2,"+>$ftput");
open (DATA3,"+>$floss");

while (<DATA>) {
@x = split(' ');


if ($x[1]-$clock <= $granularity)
{

	if ($x[0] eq 'r')
	{

		if ($x[3] eq 4)
		{

			if ($x[4] eq 'tcp')
			{
				$sum=$sum+$x[5];
			}
		}
		if ($x[3] eq 5)
		{

			if ($x[4] eq 'cbr')
			{
				$sum3=$sum3+$x[5];
			}
		}
	}
	if ($x[0] eq 'd')
	{
		if ($x[2] eq 2)
		{
			$sum2=$sum2+1;
		}
	}
}
else
{	$throughput=$sum*8/$granularity;
	$throughput2=$sum3*8/$granularity;
	$lossrate=$sum2/$granularity;
	print DATA2 "$x[1] $throughput \t $throughput2 \n";
	print DATA3 "$x[1] $lossrate \n";
	$clock=$clock+$granularity;
	$sum=0;
	$sum2=0;
	$sum3=0;
}
}
$throughput=$sum*8/$granularity;
$throughput2=$sum3*8/$granularity;
print DATA2 "$x[1] $throughput \t $throughput2 \n";
$lossrate=$sum2/$granularity;
print DATA3 "$x[1] $lossrate \n";
$clock=$clock+$granularity;
$sum=0;
$sum2=0;
$sum3=0;
close DATA;
close DATA2;
close DATA3;
exit(0);
