BEGIN { 
  data=0; 
  datalost=0;
}

 
/^r/&&/tcp/&&/1\../ { 
  data+=$6; 
}

/^d/&&/tcp/&&/1\../ { 
  datalost+=$6; 
}

END{ 
 printf("Total Data received\t: %d Bytes\n", data); 
 printf("Total Data lost\t: %d Bytes\n", datalost);
 printf("Percentage \t: %f \n", 100*data/(data+datalost));
}


