tabulador="	"
echo "timestamp	event"  >  log.txt 
fecha0=$(date +"%Y%m%d %H%M%S") 
echo "$fecha0""$tabulador""SH_START" >> log.txt 
Rscript --vanilla z531_DR_corregir_drifting.r  parametros.yml  2>&1 | tee outfile 
fecha1=$(date +"%Y%m%d %H%M%S") 
echo "$fecha1""$tabulador""SH_END" >> log.txt 
