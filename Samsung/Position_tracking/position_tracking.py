"""
Calculate metrics of trajectory deviation.
Usage:
> python position_tracking.py
Will calculate metrics of 'est' trajectory deviation from 'gt' trajectory. Create and show 3d
trajectories: 1) with original position in space and 
2) pathes are combined by common start point (0,0,0).
Generate a report 'report.txt'.
NOTE: Requires the files `gt.txt` and `est.txt`.
"""

import numpy as np
import matplotlib.pyplot as plt

from mpl_toolkits import mplot3d


gt_data = 'gt.txt'
est_data = 'est.txt'


def get_distance(point1, point2):
	"""Calculate IoU of single predicted and ground truth box
	Args:
		point1 (list of floats): [x, y, z] coords of start point
		point2 (list of floats): [x, y, z] coords of end point      
	Returns:
		float: distance between point1 and point2
	"""
	ax, ay, az = point1
	bx, by, bz = point2
	return np.sqrt((bx-ax)**2+(by-ay)**2+(bz-az)**2)


if __name__ == '__main__':
	
	# Prepare datasets for processing (delete extra records from gt)
	est_raw_data  = np.loadtxt(est_data, usecols = (0,1,2,3))
	# Transpose matrix 
	ts, est_points = est_raw_data.T[0], est_raw_data.T[1:] # ts - listOf(timestamps)
	est_points = est_points.T 	# est_points - listOf([x,y,z])
	# Skip extra data from gt
	gt_raw_data = np.loadtxt(gt_data, usecols = (0,1,2,3))
	gt_points = np.asarray([i[1:] for i in gt_raw_data if i[0] in ts])	# gt_points - listOf([x,y,z])

	#------------------------------------------------
	# Calculate Drift and Jittering
	#------------------------------------------------
	points_count = len(ts)
	total_time = ts[-1] - ts[0]	

	drift = 0
	total_drift = 0
	est_total_distance = 0
	gt_total_distance = 0

	total_jittering = 0
	max_jittering = None

	for i in range(1, points_count):
		est_abs_increment = get_distance(est_points[0], est_points[i])
		est_rel_increment = get_distance(est_points[i-1], est_points[i])
		est_total_distance += est_rel_increment

		gt_abs_increment = get_distance(gt_points[0], gt_points[i])
		gt_rel_increment = get_distance(gt_points[i-1], gt_points[i])
		gt_total_distance += gt_rel_increment

		drift = abs(gt_abs_increment - est_abs_increment)
		total_drift += drift

		jittering = abs(gt_rel_increment - est_rel_increment)
		total_jittering += jittering
		max_jittering = jittering if jittering > max_jittering else max_jittering
	
	avg_jittering = total_jittering / (points_count - 1)
	avg_drift = total_drift / (points_count - 1)
	drift_per_sec = avg_drift / total_time

	#------------------------------------------------
	# Output data
	#------------------------------------------------
	print "Time of trajectory: {:.0f}".format(total_time)
	print "Drift Per Second: {:.15f}".format(drift_per_sec)
	print "Final Drift: {:.9f}".format(drift)
	print "Max Jittering: {:.9f}".format(max_jittering)
	print "Average Jittering: {:.9f}".format(avg_jittering)
	print "Est total distance: {:.9f}".format(est_total_distance)
	print "GT total distance: {:.9f}".format(gt_total_distance)

	with open('report.txt', 'w') as report:
		report.write("Time of trajectory: {:.0f}\n".format(total_time))
		report.write("Points count per trajectory: {}\n".format(points_count))
		report.write("EST total distance: {:.9f}\n".format(est_total_distance))
		report.write("GT total distance: {:.9f}\n".format(gt_total_distance))
		report.write("-" * 80 + "\n")
		report.write("Average Drift: {:.9f}\n".format(avg_drift))
		report.write("Drift Per Second: {:.15f}\n".format(drift_per_sec))
		report.write("Final Drift: {:.9f}\n".format(drift))
		report.write("-" * 80 + "\n")
		report.write("Average Jittering: {:.9f}\n".format(avg_jittering))
		report.write("Max Jittering: {:.9f}\n".format(max_jittering))
		report.write("-" * 80 + "\n")

	#------------------------------------------------
	# Plotting trajectories
	#------------------------------------------------
	gt_x, gt_y, gt_z = gt_points.T
	est_x, est_y, est_z = est_points.T

	fig = plt.figure(figsize=plt.figaspect(0.4))

	# Subplot of original pathes
	ax = fig.add_subplot(1, 2, 1, projection='3d')
	ax.set_title("Original coords")
	ax.plot3D(gt_x, gt_y, gt_z, 'green', label = 'gt')	
	ax.plot3D(est_x, est_y, est_z, 'blue', label = 'est')

	# Subplot of pathes combined by common start point
	ax = fig.add_subplot(1, 2, 2, projection='3d')
	ax.set_title("Common start point")
	ax.plot3D(gt_x-gt_x[0], gt_y-gt_y[0], gt_z-gt_z[0], 'green', label = 'gt')	
	ax.plot3D(est_x-est_x[0], est_y-est_y[0], est_z-est_z[0], 'blue', label = 'est')

	ax.legend()

	plt.show()
