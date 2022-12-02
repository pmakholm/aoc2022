# Originally I performed the tail and summation (last perl bit) by hand
./task01.sh $1 | cut -d' ' -f3 | sort -n | tail -3 | perl -nlE '$a += $_; END { say $a } '
