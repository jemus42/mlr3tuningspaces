test_that("tuning spaces can be applied", {
  data = as.data.table(mlr_tuning_spaces)[!grepl("\\.sbb$", key)]
  mapply(test_tuning_space, data$key, data$learner)
})

test_that("sbb tuning spaces can be applied", {
  skip_if_not_installed("mlr3proba")
  skip_if_not_installed("mlr3extralearners")
  library(mlr3proba)
  library(mlr3extralearners)

  data = as.data.table(mlr_tuning_spaces)[grepl("\\.sbb$", key)]
  suppressWarnings(mapply(test_tuning_space, data$key, data$learner))
})
