rm(list = ls())

library(tidyverse)

# generate data
raw_patient_data <- 
  data.frame(patient_id = seq(1:10),
             age_years = c(rep(0, times = 7), rep(1, times = 3)),
             gestational_age = c(28, 29, 32, 34, 35, 36, 36, NA, NA, NA),
             weight_kg = c(seq(from = 2, to = 6.5, by = 0.5)),
             height_cm = c(seq(from = 30, to = 48, by = 3), 56, 63, 57),
             drug_1 = c(NA, rep("amikacin", times = 6), NA, NA, NA),
             drug_2 = c(NA, NA, rep("vancomycin", times = 6), NA, NA),
             drug_3 = c(rep("ceftriaxone", times = 3), rep(NA_character_, times = 3), rep("ceftriaxone", times = 4))
  )


# Q1: use pivot_longer() to create a column called "drug" with all antibiotic names
#     - use a selection-helper function to select the columns

patient_data <- 
  raw_patient_data %>% 
  pivot_longer(cols = starts_with("drug"),
               names_to = "old_colnames",
               values_to = "drug") %>% 
  select(-old_colnames)


# Q2: use mutate() to create the following variables:
#     - preterm: use if_else() - assign 1 if preterm or 0 if not (only preterms have "gestational_age" available)
#     - frequency: use case_when() - define frequency of administration (see slide)
#     - weight_based_dose: use recode_values() - add numbers for mg/kg dosing (see slide)
#     - single_dose: use weight_based_dose from before patient weight to calculate the individual child's dose

calculated_doses <-
  patient_data %>%
  mutate(preterm = if_else(is.na(gestational_age) == TRUE,
                           true = 1,
                           false = 0),
         frequency_h = case_when(drug == "vancomycin" & (gestational_age < 35) ~ 12,
                                 drug == "vancomycin" & (gestational_age >= 35) ~ 8,
                                 .default = 24),
         weight_based_dose = recode_values(drug,
                                           "amikacin" ~ 15,
                                           "ceftriaxone" ~ 75,
                                           "vancomycin" ~ 15),
         dose = weight_based_dose * weight_kg)


# Q3: for each drug get the highest calculated dose
#     - use group_by()
#     - use a variant of the function "slice()" (see help page)

highest_dose <- 
  calculated_doses %>% 
  group_by(drug) %>% 
  slice_max(dose, n = 1)
