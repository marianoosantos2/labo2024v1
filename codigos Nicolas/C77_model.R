# EXTRAPOLACION

# Limpieza de entorno y carga de bibliotecas
rm(list = ls(all.names = TRUE))
gc(full = TRUE)
library(data.table)

# Cargar datos
data <- fread("D:/datasets_competencia.csv")

# Calcular la proporción de ceros por 'foto_mes' y identificar combinaciones completas de ceros
ratios_cero <- data[, lapply(.SD, function(x) sum(x == 0, na.rm = TRUE) / .N), by = foto_mes]
resultados <- ratios_cero[, lapply(.SD, function(x) x == 1), by = foto_mes]
resultados_long <- melt(resultados, id.vars = "foto_mes", variable.name = "Variable", value.name = "Todos_ceros")
resultados_filtrados <- resultados_long[Todos_ceros == TRUE, .(Variable, foto_mes)]
resultados_filtrados[, Variable := gsub("Ratio_", "", Variable)]

for (i in seq_len(nrow(resultados_filtrados))) {
  var_var <- resultados_filtrados$Variable[10]
  
  var_mes  <- resultados_filtrados$foto_mes[10]
  var_mes_ant <- var_mes - 1
  var_mes_ant_ant <- var_mes - 2

  clientes_mes <- data[foto_mes == var_mes, .(numero_de_cliente)]
  clientes_mes_ant <- data[foto_mes == var_mes_ant, .(numero_de_cliente)]
  clientes_mes_ant_ant <- data[foto_mes == var_mes_ant_ant, .(numero_de_cliente)]
  clientes_com <- intersect(intersect(clientes_mes$numero_de_cliente, clientes_mes_ant$numero_de_cliente), clientes_mes_ant_ant$numero_de_cliente)
  
  valor_cliente_mes_ant <- data[foto_mes == var_mes_ant & numero_de_cliente %in% clientes_com, .(valor = get(var_var))]
  valor_cliente_mes_ant_ant <- data[foto_mes == var_mes_ant_ant & numero_de_cliente %in% clientes_com, .(valor = get(var_var))]
  print(valor_cliente_mes_ant)

  new_val <- 2 * valor_cliente_mes_ant$valor -  valor_cliente_mes_ant_ant$valor
  data[foto_mes == var_mes & numero_de_cliente %in% clientes_com, (var_var) := new_val]
  
} 
  

filtered_data <- data[foto_mes %in% c(201908, 201909, 201910, 201911) & numero_de_cliente %in% clientes_com, 
                      .(mcomisiones), 
                      by = .(numero_de_cliente, foto_mes)]

# Ahora reformatea los datos para que cada mes sea una columna
wide_format_data <- dcast(filtered_data, 
                          numero_de_cliente ~ foto_mes, 
                          value.var = "mcomisiones")
print(wide_format_data) 
  
  
  
  
  
  
  
  
  
 