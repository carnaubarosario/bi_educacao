A coluna "faixa_desempenho" foi criada diretamente no excel, como a fórmua: =SE(OU(G2="";NÃO(ÉNÚM(G2));G2<0;G2>10);"Inválido";SE(G2<5;"Baixo";SE(G2<8;"Médio";"Alto")))

A documentação do script python está na pasta "Documentações"