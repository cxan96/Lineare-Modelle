# Name: Christian Peters

# No. 3)
# ======

data <- read.csv2('wohnmobil.csv')

regressionFunction <- function(x) {
  0.0005552383 * x - 6.1106419791
}

# a)
plot(data$Verf�gbares_Einkommen_pro_Einwohner, data$Wohnmobile_pro_1000_Einwohner,
     xlab = 'Verfuegbares Jahreseinkommen (Euro)',
     ylab = 'Wohnmobile pro 1000 Einwohner',
     main = 'Wohnmobile nach Einkommen')
curve(regressionFunction, add=TRUE)

# Bewertung:
# Wie im Plot zu sehen, spiegelt die Gerade den Zusammenhang zwischen
# Jahreseinkommen und Wohnmobilanzahl recht angemessen wieder.
# Ein anderer Zusammenhang als der durch die Gerade repraesentierte lineare
# Zusammenhang erscheint mir ueberdies wenig plausibel.
# Ich sehe daher keine belastbare Grundlage dazu, die Theorie von Schorsch anzufechten.

# b)
residuals <- by(data, 1:nrow(data), function(row) {
  row$Wohnmobile_pro_1000_Einwohner - regressionFunction(row$Verf�gbares_Einkommen_pro_Einwohner)
})

plot(data$Verf�gbares_Einkommen_pro_Einwohner, residuals,
     xlab = 'Verfuegbares Jahreseinkommen (Euro)', ylab = 'Residuum',
     main = 'Residuen')
# There is no structure or pattern recognizable in the distribution of the residuals.
# It seems that the model errors are randomly distributed around zero
# which is an indicator that the linear model is an adequate fit in this situation.

# c)
# Find out, where according to the model, the most caravans can be sold.
# Places where the model's prediction is greater than the actual number of caravans
# are considered to have higher potential than places where this number is lower.
potentials <- by(data, 1:nrow(data), function(row) {
  (regressionFunction(row$Verf�gbares_Einkommen_pro_Einwohner) -
     row$Wohnmobile_pro_1000_Einwohner) * row$Einwohner / 1000
})
maxIndex <- which(potentials == max(potentials))
city <- data[maxIndex, 'Landkreis_Stadt']
print(paste0('The most promising place to open the caravan business is ', city, '.'))
# "The most promising place to open the caravan business is Dortmund."