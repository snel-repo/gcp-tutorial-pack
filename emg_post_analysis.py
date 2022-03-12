import sys
import os
import shutil
import glob
import h5py
import matplotlib.pyplot as plt
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import Ridge
from sklearn.model_selection import cross_val_score

# directory with input data file used for training
data_dir = (
    "/snel/share/share/derived/Tresch/nwb_lfads/runs/lfl_runs/run_000/lfads_input"
)
# directory with lfads output after pbt
lfads_output_dir = "/snel/share/share/derived/Tresch/nwb_lfads/runs/lfl_runs/run_000/pbt_run/best_model/"

# input data filename
data_filename = "lfads_input.h5"

# suffix for output files from lfads
output_file_suffix = "posterior_sample_and_average"

# load datasets
data_file_path = glob.glob(os.path.join(data_dir, data_filename))[0]
train_output_path = glob.glob(
    os.path.join(lfads_output_dir, "*train_" + output_file_suffix)
)[0]
valid_output_path = glob.glob(
    os.path.join(lfads_output_dir, "*valid_" + output_file_suffix)
)[0]
d_f = h5py.File(data_file_path, "r")
to_f = h5py.File(train_output_path, "r")
vo_f = h5py.File(valid_output_path, "r")

# extract lfads output
train_al_mean = to_f["output_rates"][()]
valid_al_mean = vo_f["output_rates"][()]

# extract joint angular accelerations
train_jk = d_f["train_decode"][()]
valid_jk = d_f["valid_decode"][()]


# set color of lfads
lfads_color = np.array([0.0, 140.0, 255.0]) / 255

emg_names = ["BFpR", "GA", "GRr", "GS", "IL", "RF", "SM", "ST", "TA", "VI", "VL", "VM"]
emg_plot_ixs = [3, 4, 8, 11]

fig, axs = plt.subplots(len(emg_plot_ixs), 2, figsize=(7, 10))

for i, ix in enumerate(emg_plot_ixs):
    axs[i, 0].plot(train_al_mean[:, :, ix].T, color=lfads_color, alpha=0.3)
    axs[i, 1].plot(valid_al_mean[:, :, ix].T, color=lfads_color, alpha=0.3)
    axs[i, 0].spines["top"].set_visible(False)
    axs[i, 0].spines["right"].set_visible(False)
    axs[i, 1].spines["top"].set_visible(False)
    axs[i, 1].spines["right"].set_visible(False)
    axs[i, 0].set_ylabel(emg_names[ix])
    if i == 0:
        axs[i, 0].set_title("Train")
        axs[i, 1].set_title("Valid")

train_al_flat = train_al_mean.reshape(-1, train_al_mean.shape[2])
valid_al_flat = valid_al_mean.reshape(-1, valid_al_mean.shape[2])

train_jk_flat = train_jk.reshape(-1, train_jk.shape[2])
valid_jk_flat = valid_jk.reshape(-1, valid_jk.shape[2])

X_data = np.concatenate((train_al_flat, valid_al_flat), axis=0)
y_data = np.concatenate((train_jk_flat, valid_jk_flat), axis=0)

x_ss = StandardScaler()
X_data = x_ss.fit_transform(X_data)
y_ss = StandardScaler()
y_data = y_ss.fit_transform(y_data)
lag_r2 = []
k_folds = 10
jk_preds = []
for i in range(y_data.shape[1]):
    r2_i = cross_val_score(
        Ridge(alpha=1e0), X_data, y_data[:, i], cv=k_folds, scoring="r2"
    )
    lag_r2.append(r2_i)
    vis_lr = Ridge(alpha=1e0)
    vis_lr.fit(X_data, y_data[:, i])
    jk_preds.append(vis_lr.predict(X_data))

# average cv r2
cv_r2 = np.mean(np.array(lag_r2), axis=1).round(2).tolist()
preds_flat = np.array(jk_preds).T

n_trials = train_al_mean.shape[0] + valid_al_mean.shape[0]
preds = preds_flat.reshape(n_trials, train_jk.shape[1], train_jk.shape[2])
true = y_data.reshape(n_trials, train_jk.shape[1], train_jk.shape[2])

fig, axs = plt.subplots(3, 1, figsize=(7, 10))
joint_names = ["Hip", "Knee", "Ankle"]
for i, ax in enumerate(axs):
    ax.plot(true[:, :, i].T, color="k")
    ax.plot(preds[:, :, i].T, color=lfads_color, alpha=0.3)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.set_title(joint_names[i] + " CV R2: %.2f" % cv_r2[i])

plt.show()
