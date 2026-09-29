#' @title Survival Tuning Spaces from Burk et al. (2026)
#'
#' @name mlr_tuning_spaces_sbb
#'
#' @description
#' Tuning spaces for survival learners from the `r cite_bib("burk_2026")` article.
#' The learners are provided by \CRANpkg{mlr3proba} and \pkg{mlr3extralearners}.
#'
#' The tuning spaces only cover the learner hyperparameters.
#' In the article, each learner was additionally wrapped in a preprocessing pipeline,
#' tuned with Bayesian optimization (grid search for `surv.flexspline` and `surv.rpart`),
#' and XGBoost used the outer test set for early stopping.
#' Log-transformed ranges such as \eqn{2^x, x \in [-10, 10]} are expressed as equivalent `logscale = TRUE` ranges.
#'
#' The Akritas estimator and the parametric AFT model from the article are not included,
#' because their learners were removed from \pkg{mlr3extralearners}.
#' The flexible parametric spline model uses `surv.flexspline`, the renamed `surv.flexible` learner.
#'
#' @source
#' `r format_bib("burk_2026")`
#'
#' @aliases
#' mlr_tuning_spaces_surv.cv_glmnet.sbb
#' mlr_tuning_spaces_surv.cv_ncvsurv.sbb
#' mlr_tuning_spaces_surv.penalized.sbb
#' mlr_tuning_spaces_surv.flexspline.sbb
#' mlr_tuning_spaces_surv.rfsrc.sbb
#' mlr_tuning_spaces_surv.ranger.sbb
#' mlr_tuning_spaces_surv.cforest.sbb
#' mlr_tuning_spaces_surv.aorsf.sbb
#' mlr_tuning_spaces_surv.rpart.sbb
#' mlr_tuning_spaces_surv.mboost.cox.sbb
#' mlr_tuning_spaces_surv.mboost.aft.sbb
#' mlr_tuning_spaces_surv.cv_coxboost.sbb
#' mlr_tuning_spaces_surv.xgboost.cox.sbb
#' mlr_tuning_spaces_surv.xgboost.aft.sbb
#' mlr_tuning_spaces_surv.svm.sbb
#'
#' @section cv_glmnet tuning space:
#' `r rd_info(lts("surv.cv_glmnet.sbb"))`
#'
#' @section cv_ncvsurv tuning space:
#' `r rd_info(lts("surv.cv_ncvsurv.sbb"))`
#'
#' @section penalized tuning space:
#' `r rd_info(lts("surv.penalized.sbb"))`
#'
#' @section flexspline tuning space:
#' `r rd_info(lts("surv.flexspline.sbb"))`
#'
#' @section rfsrc tuning space:
#' `r rd_info(lts("surv.rfsrc.sbb"))`
#'
#' @section ranger tuning space:
#' `r rd_info(lts("surv.ranger.sbb"))`
#'
#' @section cforest tuning space:
#' `r rd_info(lts("surv.cforest.sbb"))`
#'
#' @section aorsf tuning space:
#' `r rd_info(lts("surv.aorsf.sbb"))`
#'
#' The article also set `split_min_obs = leaf_min_events + 5`, which a tuning space cannot express.
#' To reproduce it, add the transformation to the search space:
#' `search_space = as_search_space(lts("surv.aorsf.sbb"))`,
#' `search_space$extra_trafo = function(x, param_set) {x$split_min_obs = x$leaf_min_events + 5L; x}`,
#' and pass `search_space` together with the untuned learner to [mlr3tuning::auto_tuner()].
#'
#' @section rpart tuning space:
#' `r rd_info(lts("surv.rpart.sbb"))`
#'
#' @section mboost Cox tuning space:
#' `r rd_info(lts("surv.mboost.cox.sbb"))`
#'
#' @section mboost AFT tuning space:
#' `r rd_info(lts("surv.mboost.aft.sbb"))`
#'
#' @section cv_coxboost tuning space:
#' `r rd_info(lts("surv.cv_coxboost.sbb"))`
#'
#' CoxBoost tunes itself via internal cross-validation, so this tuning space only contains constants.
#'
#' @section xgboost.cox tuning space:
#' `r rd_info(lts("surv.xgboost.cox.sbb"))`
#'
#' @section xgboost.aft tuning space:
#' `r rd_info(lts("surv.xgboost.aft.sbb"))`
#'
#' The XGBoost tuning spaces tune `nrounds` internally via early stopping,
#' so the learner's `$validate` field must be set, e.g. `lts("surv.xgboost.cox.sbb")$get_learner(validate = 0.2)`.
#'
#' @section svm tuning space:
#' `r rd_info(lts("surv.svm.sbb"))`
#'
#' @include mlr_tuning_spaces.R
#'
#' @examples
#' if (mlr3misc::require_namespaces(c("mlr3proba", "mlr3extralearners"), quietly = TRUE)) {
#'   library(mlr3proba)
#'   library(mlr3extralearners)
#'
#'   learner = lts("surv.rpart.sbb")$get_learner()
#'
#'   instance = tune(
#'     tnr("grid_search", resolution = 5),
#'     task = tsk("rats"),
#'     learner = learner,
#'     resampling = rsmp("holdout"),
#'     measures = msr("surv.cindex")
#'   )
#'
#'   instance$result
#' }
#'
#' if (mlr3misc::require_namespaces(c("mlr3proba", "mlr3extralearners", "mlr3pipelines"), quietly = TRUE)) {
#'   library(mlr3pipelines)
#'
#'   # Compose XGBoost AFT with a distribution prediction, ready to be tuned
#'   xgb_aft = ppl("distrcompositor",
#'     learner = lts("surv.xgboost.aft.sbb")$get_learner(),
#'     form = "aft",
#'     overwrite = TRUE,
#'     graph_learner = TRUE
#'   )
#'   set_validate(xgb_aft, 0.2, ids = "surv.xgboost.aft")
#'   xgb_aft
#' }
NULL

# glmnet
vals = list(
  alpha = to_tune(0, 1)
)

add_tuning_space(
  id = "surv.cv_glmnet.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.cv_glmnet",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Survival CV Elastic Net (SBB)"
)

# ncvreg, alpha = 1 selects the MCP penalty
vals = list(
  penalty = "MCP",
  alpha = 1,
  gamma = to_tune(1.0001, 10, logscale = TRUE)
)

add_tuning_space(
  id = "surv.cv_ncvsurv.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.cv_ncvsurv",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Survival CV MCP-Penalized Regression (SBB)"
)

# penalized
vals = list(
  lambda1 = to_tune(p_dbl(2^-10, 2^10, logscale = TRUE)),
  lambda2 = to_tune(p_dbl(2^-10, 2^10, logscale = TRUE))
)

add_tuning_space(
  id = "surv.penalized.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.penalized",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Survival Penalized Regression (SBB)"
)

# flexsurv
vals = list(
  k = to_tune(1, 10)
)

add_tuning_space(
  id = "surv.flexspline.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.flexspline",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Survival Flexible Parametric Splines (SBB)"
)

# rfsrc, ntime matches ranger's time.interest
vals = list(
  ntree = 1000L,
  ntime = 150L,
  splitrule = to_tune(c("bs.gradient", "logrank")),
  mtry.ratio = to_tune(0, 1),
  nodesize = to_tune(1, 50),
  samptype = to_tune(c("swr", "swor")),
  sampsize.ratio = to_tune(0, 1)
)

add_tuning_space(
  id = "surv.rfsrc.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.rfsrc",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Random Survival Forest (rfsrc) (SBB)"
)

# ranger
vals = list(
  num.trees = 1000L,
  time.interest = 150L,
  splitrule = to_tune(c("C", "maxstat", "logrank")),
  mtry.ratio = to_tune(0, 1),
  min.node.size = to_tune(1, 50),
  replace = to_tune(),
  sample.fraction = to_tune(0, 1)
)

add_tuning_space(
  id = "surv.ranger.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.ranger",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Random Survival Forest (ranger) (SBB)"
)

# cforest
vals = list(
  ntree = 1000L,
  mtryratio = to_tune(0, 1),
  minsplit = to_tune(1, 50),
  mincriterion = to_tune(0, 1),
  replace = to_tune(),
  fraction = to_tune(0, 1)
)

add_tuning_space(
  id = "surv.cforest.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.cforest",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Conditional Inference Random Survival Forest (SBB)"
)

# aorsf
vals = list(
  n_tree = 1000L,
  control_type = "fast",
  importance = "none",
  mtry_ratio = to_tune(0, 1),
  leaf_min_events = to_tune(5, 50)
)

add_tuning_space(
  id = "surv.aorsf.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.aorsf",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Oblique Random Survival Forest (SBB)"
)

# rpart
vals = list(
  minbucket = to_tune(5, 50)
)

add_tuning_space(
  id = "surv.rpart.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.rpart",
  package = "mlr3proba",
  label = "Relative Risk Tree (SBB)"
)

# mboost
vals = list(
  family = "coxph",
  mstop = to_tune(10, 5000),
  nu = to_tune(0, 0.1),
  baselearner = to_tune(c("bols", "btree"))
)

add_tuning_space(
  id = "surv.mboost.cox.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.mboost",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Model-Based Boosting Cox (SBB)"
)

vals = list(
  family = to_tune(c("gehan", "weibull")),
  mstop = to_tune(10, 5000),
  nu = to_tune(0, 0.1),
  baselearner = to_tune(c("bols", "btree"))
)

add_tuning_space(
  id = "surv.mboost.aft.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.mboost",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Model-Based Boosting AFT (SBB)"
)

# CoxBoost, K matches the inner resampling folds of the other learners
vals = list(
  penalty = "optimCoxBoostPenalty",
  maxstepno = 5000L,
  K = 3L
)

add_tuning_space(
  id = "surv.cv_coxboost.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.cv_coxboost",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Survival CV CoxBoost (SBB)"
)

# xgboost
vals = list(
  tree_method = "hist",
  booster = "gbtree",
  early_stopping_rounds = 50L,
  nrounds = to_tune(upper = 5000L, internal = TRUE, aggr = function(x) as.integer(mean(unlist(x)))),
  max_depth = to_tune(1, 20),
  subsample = to_tune(0, 1),
  colsample_bytree = to_tune(0, 1),
  learning_rate = to_tune(0, 1),
  grow_policy = to_tune(c("depthwise", "lossguide"))
)

add_tuning_space(
  id = "surv.xgboost.cox.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.xgboost.cox",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Survival XGBoost Cox (SBB)"
)

vals = c(vals, list(
  aft_loss_distribution = to_tune(c("normal", "logistic", "extreme")),
  aft_loss_distribution_scale = to_tune(0.5, 2)
))

add_tuning_space(
  id = "surv.xgboost.aft.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.xgboost.aft",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Survival XGBoost AFT (SBB)"
)

# survivalsvm
vals = list(
  type = "hybrid",
  diff.meth = "makediff3",
  kernel = to_tune(c("lin_kernel", "rbf_kernel", "add_kernel")),
  gamma = to_tune(1e-10, 1e10, logscale = TRUE),
  mu = to_tune(1e-10, 1e10, logscale = TRUE),
  kernel.pars = to_tune(p_dbl(2^-5, 2^5, logscale = TRUE))
)

add_tuning_space(
  id = "surv.svm.sbb",
  values = vals,
  tags = c("sbb", "survival"),
  learner = "surv.svm",
  package = c("mlr3proba", "mlr3extralearners"),
  label = "Survival SVM (SBB)"
)
