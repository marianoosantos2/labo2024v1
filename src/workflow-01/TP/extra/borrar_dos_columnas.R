# limpio la memoria
rm(list = ls(all.names = TRUE)) # remove all objects
gc(full = TRUE) # garbage collection


## Instalamos los paquetes dinámicamente en el ambiente
packages = c("rlang", "yaml", "data.table", "ParamHelpers","Boruta")

require("data.table")


dt <- fread("C:\\Users\\Mariano_Santos\\OneDrive - Universidad Austral\\00 datos\\08-Laboratorio_implementacion_I\\datasets\\datasets_competencia_2024_2.csv.gz")
                  #C:\Users\Mariano_Santos\OneDrive - Universidad Austral\00 datos\08-Laboratorio_implementacion_I\datasets


head(dt)

num_cols_before <- ncol(dt)
print(paste("Cantidad de columnas antes de eliminar:", num_cols_before))




if ("Master_Finiciomora" %in% names(dt)) {
  dt[, Master_Finiciomora := NULL]
}

if ("Visa_Finiciomora" %in% names(dt)) {
  dt[, Visa_Finiciomora := NULL]
}

num_cols_after <- ncol(dt)
print(paste("Cantidad de columnas después de eliminar:", num_cols_after))
head(dt)

new_filename <- "C:\\Users\\Mariano_Santos\\OneDrive - Universidad Austral\\00 datos\\08-Laboratorio_implementacion_I\\datasets\\datasets_competencia_2024_2.csv.gz"  # Cambia el nombre del archivo de salida
fwrite(dt, new_filename)
