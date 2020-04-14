.onLoad <- function(libname, pkgname){
  if (requireNamespace("mlr3", quietly = TRUE)) {
    MeasureClassifAUPRC <- R6::R6Class("MeasureClassifAUPRC",
                inherit = mlr3::MeasureClassif,
                public = list(
                  initialize = function() {
                    super$initialize(
                      id = "classif.auprc",
                      range = c(0, 1),
                      minimize = TRUE,
                      predict_type = "prob",
                      task_properties = "twoclass",
                      packages = "auprc"
                    )
                  },
                  .score = function(prediction, ...) {
                    positive <- levels(prediction$truth)[1]
                    auprc(prediction$data$prob[, positive],
                          prediction$data$tab$truth,
                          positive)
                  }
                )
    )
    mlr3::mlr_measures$add("classif.auprc", MeasureClassifAUPRC)
  }
}