# Experimentos Colaborativos Default
# Workflow  Catastrophe Analysis

# limpio la memoria
rm(list = ls(all.names = TRUE)) # remove all objects
gc(full = TRUE) # garbage collection

require("data.table")
require("yaml")

# Parametros del script
PARAM <- read_yaml( "parametros.yml" )


OUTPUT <- list()

#------------------------------------------------------------------------------

options(error = function() {
  traceback(20)
  options(error = NULL)
  
  t <- format(Sys.time(), "%Y%m%d %H%M%S")
  cat( t, "\n",
    file = "z-Rabort.txt",
    append = TRUE
  )

  cat( t, "\n",
    file = "z-Rabort-hist.txt",
    append = TRUE
  )

  stop("exiting after script error")
})
#------------------------------------------------------------------------------

GrabarOutput <- function() {
  write_yaml(OUTPUT, file = "output.yml") # grabo output
}
#------------------------------------------------------------------------------

CorregirCampoMes <- function(pcampo, pmeses) {

  tbl <- dataset[, list(
    "v1" = shift(get(pcampo), 1, type = "lag"),
    "v2" = shift(get(pcampo), 1, type = "lead")
  ),
  by = eval(PARAM$dataset_metadata$entity_id)
  ]

  tbl[, paste0(PARAM$dataset_metadata$entity_id) := NULL]
  tbl[, promedio := rowMeans(tbl, na.rm = TRUE)]

  dataset[
    ,
    paste0(pcampo) := ifelse(!(foto_mes %in% pmeses),
      get(pcampo),
      tbl$promedio
    )
  ]
}
#------------------------------------------------------------------------------
# reemplaza cada variable ROTA  (variable, foto_mes)
#  con el promedio entre  ( mes_anterior, mes_posterior )

Corregir_EstadisticaClasica <- function(dataset) {
  CorregirCampoMes("thomebanking", c(201801, 202006))
  CorregirCampoMes("chomebanking_transacciones", c(201801, 201910, 202006))
  CorregirCampoMes("tcallcenter", c(201801, 201806, 202006))
  CorregirCampoMes("ccallcenter_transacciones", c(201801, 201806, 202006))
  CorregirCampoMes("cprestamos_personales", c(201801, 202006))
  CorregirCampoMes("mprestamos_personales", c(201801, 202006))
  CorregirCampoMes("mprestamos_hipotecarios", c(201801, 202006))
  CorregirCampoMes("ccajas_transacciones", c(201801, 202006))
  CorregirCampoMes("ccajas_consultas", c(201801, 202006))
  CorregirCampoMes("ccajas_depositos", c(201801, 202006))
  CorregirCampoMes("ccajas_extracciones", c(201801, 202006))
  CorregirCampoMes("ccajas_otras", c(201801, 202006))

  CorregirCampoMes("ctarjeta_visa_debitos_automaticos", c(201904))
  CorregirCampoMes("mttarjeta_visa_debitos_automaticos", c(201904, 201905))
  CorregirCampoMes("Visa_mfinanciacion_limite", c(201904))

  CorregirCampoMes("mrentabilidad", c(201905, 201910, 202006))
  CorregirCampoMes("mrentabilidad_annual", c(201905, 201910, 202006))
  CorregirCampoMes("mcomisiones", c(201905, 201910, 202006))
  CorregirCampoMes("mpasivos_margen", c(201905, 201910, 202006))
  CorregirCampoMes("mactivos_margen", c(201905, 201910, 202006))
  CorregirCampoMes("ccomisiones_otras", c(201905, 201910, 202006))
  CorregirCampoMes("mcomisiones_otras", c(201905, 201910, 202006))

  CorregirCampoMes("ctarjeta_visa_descuentos", c(201910))
  CorregirCampoMes("ctarjeta_master_descuentos", c(201910))
  CorregirCampoMes("mtarjeta_visa_descuentos", c(201910))
  CorregirCampoMes("mtarjeta_master_descuentos", c(201910))
  CorregirCampoMes("ccajeros_propios_descuentos", c(201910))
  CorregirCampoMes("mcajeros_propios_descuentos", c(201910))

  CorregirCampoMes("cliente_vip", c(201911))

  CorregirCampoMes("active_quarter", c(202006))
  CorregirCampoMes("mcuentas_saldo", c(202006))
  CorregirCampoMes("ctarjeta_debito_transacciones", c(202006))
  CorregirCampoMes("mautoservicio", c(202006))
  CorregirCampoMes("ctarjeta_visa_transacciones", c(202006))
  CorregirCampoMes("ctarjeta_visa_transacciones", c(202006))
  CorregirCampoMes("cextraccion_autoservicio", c(202006))
  CorregirCampoMes("mextraccion_autoservicio", c(202006))
  CorregirCampoMes("ccheques_depositados", c(202006))
  CorregirCampoMes("mcheques_depositados", c(202006))
  CorregirCampoMes("mcheques_emitidos", c(202006))
  CorregirCampoMes("mcheques_emitidos", c(202006))
  CorregirCampoMes("ccheques_depositados_rechazados", c(202006))
  CorregirCampoMes("mcheques_depositados_rechazados", c(202006))
  CorregirCampoMes("ccheques_emitidos_rechazados", c(202006))
  CorregirCampoMes("mcheques_emitidos_rechazados", c(202006))
  CorregirCampoMes("catm_trx", c(202006))
  CorregirCampoMes("matm", c(202006))
  CorregirCampoMes("catm_trx_other", c(202006))
  CorregirCampoMes("matm_other", c(202006))
  CorregirCampoMes("cmobile_app_trx", c(202006))
}
#------------------------------------------------------------------------------

Corregir_MachineLearning <- function(dataset) {
  gc()
  
  #reemplazo los NaN por Na.
  dataset[, (names(dataset)) := lapply(.SD, function(col) {
    if (is.numeric(col)) {
      col[is.nan(col)] <- NA
    }
    return(col)
  })]
  # acomodo los errores del dataset
  
  dataset[foto_mes == 201901, ctransferencias_recibidas := NA]
  dataset[foto_mes == 201901, mtransferencias_recibidas := NA]

  dataset[foto_mes == 201902, ctransferencias_recibidas := NA]
  dataset[foto_mes == 201902, mtransferencias_recibidas := NA]

  dataset[foto_mes == 201903, ctransferencias_recibidas := NA]
  dataset[foto_mes == 201903, mtransferencias_recibidas := NA]

  dataset[foto_mes == 201904, ctransferencias_recibidas := NA]
  dataset[foto_mes == 201904, mtransferencias_recibidas := NA]
  dataset[foto_mes == 201904, ctarjeta_visa_debitos_automaticos := NA]
  dataset[foto_mes == 201904, mttarjeta_visa_debitos_automaticos := NA]
  dataset[foto_mes == 201904, Visa_mfinanciacion_limite := NA]

  dataset[foto_mes == 201905, ctransferencias_recibidas := NA]
  dataset[foto_mes == 201905, mtransferencias_recibidas := NA]
  dataset[foto_mes == 201905, mrentabilidad := NA]
  dataset[foto_mes == 201905, mrentabilidad_annual := NA]
  dataset[foto_mes == 201905, mcomisiones := NA]
  dataset[foto_mes == 201905, mpasivos_margen := NA]
  dataset[foto_mes == 201905, mactivos_margen := NA]
  dataset[foto_mes == 201905, ctarjeta_visa_debitos_automaticos := NA]
  dataset[foto_mes == 201905, ccomisiones_otras := NA]
  dataset[foto_mes == 201905, mcomisiones_otras := NA]

  dataset[foto_mes == 201910, mpasivos_margen := NA]
  dataset[foto_mes == 201910, mactivos_margen := NA]
  dataset[foto_mes == 201910, ccomisiones_otras := NA]
  dataset[foto_mes == 201910, mcomisiones_otras := NA]
  dataset[foto_mes == 201910, mcomisiones := NA]
  dataset[foto_mes == 201910, mrentabilidad := NA]
  dataset[foto_mes == 201910, mrentabilidad_annual := NA]
  dataset[foto_mes == 201910, chomebanking_transacciones := NA]
  dataset[foto_mes == 201910, ctarjeta_visa_descuentos := NA]
  dataset[foto_mes == 201910, ctarjeta_master_descuentos := NA]
  dataset[foto_mes == 201910, mtarjeta_visa_descuentos := NA]
  dataset[foto_mes == 201910, mtarjeta_master_descuentos := NA]
  dataset[foto_mes == 201910, ccajeros_propios_descuentos := NA]
  dataset[foto_mes == 201910, mcajeros_propios_descuentos := NA]

  dataset[foto_mes == 202001, cliente_vip := NA]

  dataset[foto_mes == 202006, active_quarter := NA]
  dataset[foto_mes == 202006, mrentabilidad := NA]
  dataset[foto_mes == 202006, mrentabilidad_annual := NA]
  dataset[foto_mes == 202006, mcomisiones := NA]
  dataset[foto_mes == 202006, mactivos_margen := NA]
  dataset[foto_mes == 202006, mpasivos_margen := NA]
  dataset[foto_mes == 202006, mcuentas_saldo := NA]
  dataset[foto_mes == 202006, ctarjeta_debito_transacciones := NA]
  dataset[foto_mes == 202006, mautoservicio := NA]
  dataset[foto_mes == 202006, ctarjeta_visa_transacciones := NA]
  dataset[foto_mes == 202006, mtarjeta_visa_consumo := NA]
  dataset[foto_mes == 202006, ctarjeta_master_transacciones := NA]
  dataset[foto_mes == 202006, mtarjeta_master_consumo := NA]
  dataset[foto_mes == 202006, ccomisiones_otras := NA]
  dataset[foto_mes == 202006, mcomisiones_otras := NA]
  dataset[foto_mes == 202006, cextraccion_autoservicio := NA]
  dataset[foto_mes == 202006, mextraccion_autoservicio := NA]
  dataset[foto_mes == 202006, ccheques_depositados := NA]
  dataset[foto_mes == 202006, mcheques_depositados := NA]
  dataset[foto_mes == 202006, ccheques_emitidos := NA]
  dataset[foto_mes == 202006, mcheques_emitidos := NA]
  dataset[foto_mes == 202006, ccheques_depositados_rechazados := NA]
  dataset[foto_mes == 202006, mcheques_depositados_rechazados := NA]
  dataset[foto_mes == 202006, ccheques_emitidos_rechazados := NA]
  dataset[foto_mes == 202006, mcheques_emitidos_rechazados := NA]
  dataset[foto_mes == 202006, tcallcenter := NA]
  dataset[foto_mes == 202006, ccallcenter_transacciones := NA]
  dataset[foto_mes == 202006, thomebanking := NA]
  dataset[foto_mes == 202006, chomebanking_transacciones := NA]
  dataset[foto_mes == 202006, ccajas_transacciones := NA]
  dataset[foto_mes == 202006, ccajas_consultas := NA]
  dataset[foto_mes == 202006, ccajas_depositos := NA]
  dataset[foto_mes == 202006, ccajas_extracciones := NA]
  dataset[foto_mes == 202006, ccajas_otras := NA]
  dataset[foto_mes == 202006, catm_trx := NA]
  dataset[foto_mes == 202006, matm := NA]
  dataset[foto_mes == 202006, catm_trx_other := NA]
  dataset[foto_mes == 202006, matm_other := NA]
  dataset[foto_mes == 202006, ctrx_quarter := NA]
  dataset[foto_mes == 202006, cmobile_app_trx := NA]
}
#------------------------------------------------------------------------------
Corregir_media <- function(dataset) {
  gc()
  # acomodo los errores del dataset(dataset),
  ratios_cero <- dataset[, lapply(.SD, function(x) sum(x == 0, na.rm = TRUE) / .N), by = foto_mes]
  resultados <- ratios_cero[, lapply(.SD, function(x) x == 1), by = foto_mes]
  resultados_long <- melt(resultados, id.vars = "foto_mes", variable.name = "Variable", value.name = "Todos_ceros")
  resultados_filtrados <- resultados_long[Todos_ceros == TRUE, .(Variable, foto_mes)]
  resultados_filtrados[, Variable := gsub("Ratio_", "", Variable)]
  
  # Calcular promedio registro a registro entre valores mes anterior y posterior, y asignar.
  for (i in seq_len(nrow(resultados_filtrados))) {
    var_var <- resultados_filtrados$Variable[i]
    var_mes  <- resultados_filtrados$foto_mes[i]
    var_mes_ant <- var_mes - 1
    var_mes_pos <- var_mes + 1
    
    clientes_mes <- dataset[foto_mes == var_mes, .(numero_de_cliente)]
    clientes_mes_ant <- dataset[foto_mes == var_mes_ant, .(numero_de_cliente)]
    clientes_mes_pos <- dataset[foto_mes == var_mes_pos, .(numero_de_cliente)]
    
    clientes_com <- intersect(intersect(clientes_mes$numero_de_cliente, clientes_mes_ant$numero_de_cliente), clientes_mes_pos$numero_de_cliente)
    valor_cliente_mes_ant <- dataset[foto_mes == var_mes_ant & numero_de_cliente %in% clientes_com, .(numero_de_cliente, valor = get(var_var))]
    valor_cliente_mes_pos <- dataset[foto_mes == var_mes_pos & numero_de_cliente %in% clientes_com, .(numero_de_cliente, valor = get(var_var))]
    
    merged_data <- merge(valor_cliente_mes_ant, valor_cliente_mes_pos, by = "numero_de_cliente", suffixes = c("_ant", "_pos"))
    merged_data[, valor_promedio := (valor_ant + valor_pos) / 2]
    
    dataset[, (var_var) := as.numeric(get(var_var))]
    dataset[foto_mes == var_mes & numero_de_cliente %in% clientes_com, (var_var) := merged_data[.SD, on = .(numero_de_cliente), x.valor_promedio]]
}
}
#------------------------------------------------------------------------------
# PROMEDIO VALOR A VALOR Y IMPUTACION A CERO RATIO PROMEDIO.
Corregir_ratio_prom <- function(dataset) {
  gc()


# Calcular la proporción de ceros por 'foto_mes' y identificar combinaciones completas de ceros
ratios_cero <- dataset[, lapply(.SD, function(x) sum(x == 0, na.rm = TRUE) / .N), by = foto_mes]
resultados <- ratios_cero[, lapply(.SD, function(x) x == 1), by = foto_mes]
resultados_long <- melt(resultados, id.vars = "foto_mes", variable.name = "Variable", value.name = "Todos_ceros")
resultados_filtrados <- resultados_long[Todos_ceros == TRUE, .(Variable, foto_mes)]
resultados_filtrados[, Variable := gsub("Ratio_", "", Variable)]

for (i in seq_len(nrow(resultados_filtrados))) {
  var_var <- resultados_filtrados$Variable[i]
  var_mes  <- resultados_filtrados$foto_mes[i]
  var_mes_ant <- var_mes - 1
  var_mes_pos <- var_mes + 1
  
  res_mes <- dataset[foto_mes == var_mes, .(Total = .N, Ceros = sum(get(var_var) == 0, na.rm = TRUE))]
  res_mes_ant <- dataset[foto_mes == var_mes_ant, .(Total = .N, Ceros = sum(get(var_var) == 0, na.rm = TRUE))]
  res_mes_pos <- dataset[foto_mes == var_mes_pos, .(Total = .N, Ceros = sum(get(var_var) == 0, na.rm = TRUE))]
  ratio_ant <- res_mes_ant$Ceros / res_mes_pos$Total
  ratio_pos <- res_mes_pos$Ceros / res_mes_pos$Total
  ratio_med <- (ratio_ant + ratio_pos) / 2
  
  clientes_mes <- dataset[foto_mes == var_mes, .(numero_de_cliente)]
  clientes_mes_ant <- dataset[foto_mes == var_mes_ant, .(numero_de_cliente)]
  clientes_mes_pos <- dataset[foto_mes == var_mes_pos, .(numero_de_cliente)]
  
  clientes_com <- intersect(intersect(clientes_mes$numero_de_cliente, clientes_mes_ant$numero_de_cliente), clientes_mes_pos$numero_de_cliente)
  valor_cliente_mes_ant <- dataset[foto_mes == var_mes_ant & numero_de_cliente %in% clientes_com, .(numero_de_cliente, valor = get(var_var))]
  valor_cliente_mes_pos <- dataset[foto_mes == var_mes_pos & numero_de_cliente %in% clientes_com, .(numero_de_cliente, valor = get(var_var))]
  
  merged_data <- merge(valor_cliente_mes_ant, valor_cliente_mes_pos, by = "numero_de_cliente", suffixes = c("_ant", "_pos"))
  merged_data[, valor_promedio := (valor_ant + valor_pos) / 2]
  merged_data[, valor_prom_abs := abs(valor_promedio)]
  
  setorder(merged_data, valor_prom_abs)
  n_row <- nrow(merged_data)
  n_record <-floor(n_row * ratio_med)
  merged_data[1:n_record, valor_promedio := 0]
  dataset[, (var_var) := as.numeric(get(var_var))]
  dataset[foto_mes == var_mes & numero_de_cliente %in% clientes_com, (var_var) := merged_data[.SD, on = .(numero_de_cliente), x.valor_promedio]]
} 
}
#------------------------------------------------------------------------------
# EXTRAPOLACION CON MES ANTERIOR Y ANTERIOR-ANTERIOR
Corregir_extrapolar <- function(dataset) {
  gc()


# Calcular la proporción de ceros por 'foto_mes' y identificar combinaciones completas de ceros
ratios_cero <- dataset[, lapply(.SD, function(x) sum(x == 0, na.rm = TRUE) / .N), by = foto_mes]
resultados <- ratios_cero[, lapply(.SD, function(x) x == 1), by = foto_mes]
resultados_long <- melt(resultados, id.vars = "foto_mes", variable.name = "Variable", value.name = "Todos_ceros")
resultados_filtrados <- resultados_long[Todos_ceros == TRUE, .(Variable, foto_mes)]
resultados_filtrados[, Variable := gsub("Ratio_", "", Variable)]

for (i in seq_len(nrow(resultados_filtrados))) {
  var_var <- resultados_filtrados$Variable[i]
  
  var_mes  <- resultados_filtrados$foto_mes[i]
  var_mes_ant <- var_mes - 1
  var_mes_ant_ant <- var_mes - 2
  
  clientes_mes <- dataset[foto_mes == var_mes, .(numero_de_cliente)]
  clientes_mes_ant <- dataset[foto_mes == var_mes_ant, .(numero_de_cliente)]
  clientes_mes_ant_ant <- dataset[foto_mes == var_mes_ant_ant, .(numero_de_cliente)]
  clientes_com <- intersect(intersect(clientes_mes$numero_de_cliente, clientes_mes_ant$numero_de_cliente), clientes_mes_ant_ant$numero_de_cliente)
  
  valor_cliente_mes_ant <- dataset[foto_mes == var_mes_ant & numero_de_cliente %in% clientes_com, .(valor = get(var_var))]
  valor_cliente_mes_ant_ant <- dataset[foto_mes == var_mes_ant_ant & numero_de_cliente %in% clientes_com, .(valor = get(var_var))]
  print(valor_cliente_mes_ant)
  
  new_val <- 2 * valor_cliente_mes_ant$valor -  valor_cliente_mes_ant_ant$valor
  dataset[foto_mes == var_mes & numero_de_cliente %in% clientes_com, (var_var) := new_val]
  
} 
}




#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Aqui empieza el programa
OUTPUT$PARAM <- PARAM
OUTPUT$time$start <- format(Sys.time(), "%Y%m%d %H%M%S")


# cargo el dataset
PARAM$dataset <- paste0( "./", PARAM$input, "/dataset.csv.gz" )
PARAM$dataset_metadata <- read_yaml( paste0( "./", PARAM$input, "/dataset_metadata.yml" ) )

dataset <- fread(PARAM$dataset)

# tmobile_app se daño a partir de 202010
dataset[, tmobile_app := NULL]


GrabarOutput()

# ordeno dataset
setorderv(dataset, PARAM$dataset_metadata$primarykey)

# corrijo los  < foto_mes, campo >  que fueron pisados con cero
switch(PARAM$metodo,
  "MachineLearning"     = Corregir_MachineLearning(dataset),
  "EstadisticaClasica"  = Corregir_EstadisticaClasica(dataset),
  "medias"              = Corregir_media(dataset),
  "extrapolar"          = Corregir_extrapolar(dataset),
  "locf"                = Corregir_locf(dataset),
  "inter_random"        = Corregir_InterRandom(dataset),
  "ratio_prom"          = Corregir_ratio_prom(dataset),
  "Ninguno"             = cat("No se aplica ninguna correccion.\n"),
)


#------------------------------------------------------------------------------
# grabo el dataset

fwrite(dataset,
  file = "dataset.csv.gz",
  logical01 = TRUE,
  sep = ","
)

# copia la metadata sin modificar
write_yaml( PARAM$dataset_metadata, 
  file="dataset_metadata.yml" )

#------------------------------------------------------------------------------

# guardo los campos que tiene el dataset
tb_campos <- as.data.table(list(
  "pos" = 1:ncol(dataset),
  "campo" = names(sapply(dataset, class)),
  "tipo" = sapply(dataset, class),
  "nulos" = sapply(dataset, function(x) {
    sum(is.na(x))
  }),
  "ceros" = sapply(dataset, function(x) {
    sum(x == 0, na.rm = TRUE)
  })
))

fwrite(tb_campos,
  file = "dataset.campos.txt",
  sep = "\t"
)

#------------------------------------------------------------------------------
OUTPUT$dataset$ncol <- ncol(dataset)
OUTPUT$dataset$nrow <- nrow(dataset)
OUTPUT$time$end <- format(Sys.time(), "%Y%m%d %H%M%S")
GrabarOutput()

# dejo la marca final
cat(format(Sys.time(), "%Y%m%d %H%M%S"), "\n",
  file = "z-Rend.txt",
  append = TRUE
)
