#' performance_bivariado_transf_log
#'
#' group values of ordinal varibles according to a target variable
#' .
#' @param tbla table with data. It has to have the variable and the target variable.
#' @param variable_name name of the variable that you want to analyze.
#' @param target-name name of the target variable.
#' @keywords
#' @export
#' @examples
#' set.seed(1)
#' x1 = rnorm(1000)
#' x2 = rnorm(1000)
#' x3= ifelse(as.factor(x2>0.5)==T, 'A', 'B')
#' z = 1 + 2 \* x1 + 3 \* x2
# #' z = 1 + 2 * x1 + 3 * x2
#' pr = 1/(1+exp(-z))
#' y = rbinom(1000,1,pr)
#' tbla = data.frame(y=y,x1=x1,x2=x2, x3=x3)
#' tbla[ 1:10, 'x1']<-NA  #generate NA
#' performance_bivariado_transf_log (tbla, variable_name='x1',target_name='y' )
#' performance_bivariado_transf_log (tbla, variable_name='x2',target_name='y' )

performance_bivariado_transf_log<-function(tbla, variable_name, target_name, limite_steps){

  tbla<-data.frame(tbla)
  tbla$y<-tbla[, target_name]

  tbla[, variable_name]<- as.numeric(tbla[, variable_name])
  #verifica NA
  index_nas=is.na(tbla[,variable_name])

  nas=sum(index_nas)
  #imputa nas
  media=round(mean(tbla[index_nas==F,variable_name]),4)
  print(paste0( variable_name, ' .NAs: ', nas, ' .Imputada con: ', media))
  tbla[index_nas,variable_name]<-media

  #verifica infinite
  index_infs<-is.infinite(tbla[,variable_name])
  infs=sum(index_infs)
  #imputa infs
  print(paste0( variable_name, ' .Infs: ', infs, ' .Imputada con: 0'))
  tbla[index_infs,variable_name]<-0


  #flag de faltante
  nombre0=paste0(variable_name, '_', 'flag_nas_infs')
  tbla[,nombre0]<-as.numeric(index_infs|index_nas)


  print('aplica transformaciones')
  nombre1=paste0(variable_name, '_', 'al2')
  tbla[,nombre1]<-tbla[,variable_name]**2
  #head(tbla);tail(tbla)

  nombre2=paste0(variable_name, '_', 'al3')
  tbla[,nombre2]<-tbla[,variable_name]**3

  nombre3=paste0(variable_name, '_', 'al4')
  tbla[,nombre3]<-tbla[,variable_name]**4

  signos0=sign(tbla[,variable_name])
  signos=ifelse(signos0 ==0,1,signos0)

  nombre4=paste0(variable_name, '_', 'raiz2')
  tbla[,nombre4]<-(abs(tbla[,variable_name])**(1/2))* signos

  nombre5=paste0(variable_name, '_', 'logaritmo')
  min_abs=max(min(abs(tbla[,variable_name])), 0.01)
  tbla[,nombre5]<-log(abs(tbla[,variable_name])+min_abs/100) * signos

  print('entrena logistica')

  form_2=paste0(nombre0, ' * (',paste(c(variable_name, nombre1, nombre2, nombre3, nombre4, nombre5), collapse=' + '), ')')

  #form_2=paste(c(variable_name, nombre0, nombre1, nombre2, nombre3, nombre4, nombre5), collapse=' + ')
  form_all=formula(paste0('y ~ ', form_2))

  tbla2<-tbla
  #calcula el poder predictivo de la variable sobre los datos que hay
  print('con nas')
  devuelve_con_na=performance_modelo_logistica(tbla2, mod_all, variable_name, form_all, limite_steps)


  print('sin nas')
  tbla3<-tbla[index_nas==F,]
  #calcula el poder predictivo sobre los que tenemos datos
  devuelve_sin_na=performance_modelo_logistica(tbla3, mod_all, variable_name, form_all, limite_steps)

  colnames(devuelve_sin_na)<-paste0(colnames(devuelve_sin_na), '_sin_na')

  devuelve=merge(devuelve_con_na, devuelve_sin_na, by.x='variable_name', by.y='variable_name_sin_na', all.x=T, all.y=T)

  ##le pego los na que tiene

  devuelve$cant_nas=nas

  return(devuelve)

}
