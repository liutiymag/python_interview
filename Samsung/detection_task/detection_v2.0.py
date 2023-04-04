"""
Calculate Precision and Recall for a set of bounding boxes corresponding to specific
image-labels Ids.
Usage:
> python detection.py
Will calculate Precision an Recall for pedestrian objects bboxes. Create and save image
describing density of bboxes centres for predicted and groundtruth data sets ('centres.png').
Create a report 'report.txt'.
NOTE: Requires the files `predicted.h5` and `groundtruth.h5`.
"""

import numpy as np

import h5py as h5
import warnings
import time
from matplotlib import pyplot as plt, cbook

predict_true = 0 # Successfully predicted bbox count
processed_lables_count = 0 # Amount of processed common images
predicted_processed_count = 0 # Amount of compared predicted bboxes
gt_processed_count = 0 # Amount of compared grountruth bboxes


def make_labels_array(data_set):
    """Make numpy array with boxes referenced to labels, count pedestrians objects
    Args:
        data_set: initial HDF data set
    Returns:
        array: [label, xmin, ymin, xmax, ymax]
        int: count of pedestrians objects in data set
    """
    objects = np.array(data_set['obj_type'], ndmin = 2)
    labels = np.array(data_set['label_name'], ndmin = 2)
    bboxes = np.array(data_set['bbox2d'], dtype = float)

    condition = np.logical_or(objects=='Pedestrian', objects=='pedestrian')[0]
    result = np.concatenate((labels.T, bboxes), axis = 1)[condition]
    result = np.asarray(result, dtype=np.float32)
    return result, result.shape[0]

def calc_iou(gt_bb, pr_bb):
    """Calculate IoU of single predicted and ground truth box
    Args:
        gt_bb (list of floats): location of ground truth object as
            [xmin, ymin, xmax, ymax]
        pr_bb (list of floats): location of predicted object as
            [xmin, ymin, xmax, ymax]        
    Returns:
        float: value of the IoU for the two boxes
    """
    x1_t, y1_t, x2_t, y2_t = gt_bb
    x1_p, y1_p, x2_p, y2_p = pr_bb

    if (x2_t < x1_p or x2_p < x1_t or y2_t < y1_p or y2_p < y1_t):
        return 0.0

    far_x = min([x2_t, x2_p])
    near_x = max([x1_t, x1_p])
    far_y = min([y2_t, y2_p])
    near_y = max([y1_t, y1_p])

    inter_area = (far_x - near_x) * (far_y - near_y)
    gt_bb_area = (x2_t - x1_t) * (y2_t - y1_t)
    pr_bb_area = (x2_p - x1_p) * (y2_p - y1_p)
    iou = inter_area / (gt_bb_area + pr_bb_area - inter_area) * 100
    return iou

def plot_centres(data_array, sub_plot, ploting_str = 'b.'):
    """Put the centeres of boxes into subplot
    Args:
        data_array (list of (list of floats)): location of bbox as
            [[xmin, ymin, xmax, ymax]] 
        sub_plot: plot to add center into
        plotting_str: string of plotting params (style, color)    
    """
    _, xmin, ymin, xmax, ymax = data_array.T
    x = xmin + (xmax - xmin) / 2.0
    y = ymin + (ymax - ymin) / 2.0
    sub_plot.plot(x, y, ploting_str)


if __name__ == "__main__":
	# Set value of IoU to consider as threshold for a true prediction
    try:
        iou_thr = int(input("Enter Intersection Over Union treshold (0..100) %: "))
        if iou_thr > 100 or iou_thr < 0:
            iou_thr = 50 # Default value
    except:
        iou_thr = 50 # Default value

    warnings.filterwarnings("ignore",category=cbook.mplDeprecation)
    print ("Current value of IoU to consider as threshold for a \
true prediction is: {}%".format(iou_thr))
    start_time = time.time()

    # Prepare plot params
    f, (pred_sp, gt_sp) = plt.subplots(2, sharex=True, sharey=True)
    pred_sp.set_title('Predicted bbox centres')
    gt_sp.set_title('Groudtruth bbox centres')

    # Read H5 file
    pr_data = h5.File("predicted.h5", "r")
    gt_data = h5.File("groundtruth.h5", "r")        

    # Make numpy arrays with elements [label, bbox1_coords, bbox2_coords, ...]
    predicted_array, predicted_pedestrians = make_labels_array(pr_data)
    print 'predicted pedestrians: %d' %  predicted_pedestrians

    groundtruth_array, groundtruth_pedestrians = make_labels_array(gt_data)
    print 'groundtruth pedestrians: %d \n' %  groundtruth_pedestrians

    predicted_lables = predicted_array.take(0, axis = 1)
    predicted_lables_set = np.unique(predicted_lables)
    groundtruth_lables = groundtruth_array.take(0, axis = 1)
    groundtruth_lables_set = np.unique(groundtruth_lables)
    
    # Compare
    for label in predicted_lables_set:
        predicted_bbxs = predicted_array[(predicted_lables==label)] # Get bboxes with current labels
        predicted_bbxs = predicted_bbxs.take((1,2,3,4), axis = 1) # Get [[xmin, ymin, xmax, ymax]]
                                 
        groundtruth_bbxs = groundtruth_array[(groundtruth_lables==label)]
        if len(groundtruth_bbxs) > 0:    # Does groundtruth label exist
            groundtruth_bbxs = groundtruth_bbxs.take((1,2,3,4), axis = 1)
            gt_label_present = True
            processed_lables_count += 1
        else:
            gt_label_present = False

        gt_detected = set()
        first_circle = True
        for pr_bb in predicted_bbxs:
            iou_max = 0.0            
            if gt_label_present:                
                predicted_processed_count += 1
                for i, gt_bb in enumerate(groundtruth_bbxs):
                    if first_circle:
                        gt_processed_count += 1
                    iou = calc_iou(gt_bb, pr_bb)
                    if iou > iou_max:
                        iou_max = iou
                        iou_max_inx = i
                if iou_max >= iou_thr:
                    gt_detected.add(iou_max_inx)
                first_circle = False
        predict_true += len(gt_detected)

    # Calculate Precision and Recall
    try:
        precision = float(predict_true) / float(predicted_pedestrians)
    except ZeroDivisionError:
        precision = 0.0
    try:
        recall = float(predict_true) / float(groundtruth_pedestrians)
    except ZeroDivisionError:
        recall = 0.0

    # Plotting
    plot_centres(predicted_array, pred_sp, 'b.')
    plot_centres(groundtruth_array, gt_sp, 'g.')

    # Print\save report and plot      
    stop_time = time.time()
    print "Precision: %.3f" %  precision
    print "Recall: %.3f \n" %  recall
    print "-" * 80 + "\n"
    print "Report generated: 'report.txt'"
    print "Plot generated: 'centres.png'"
    print "Processing time: %.2f sec \n" %  (stop_time - start_time)
    
    with open('report.txt', 'w') as report:
        report.write(" " * 30 + "Predicted data set" + " " * 10 + "Grountruth data set\n")
        report.write("Total records count:")    
        report.write("{:^40} {:^18} \n".format(len(pr_data['label_name']), len(gt_data['label_name'])))    
        report.write("Total pedestrians count:")
        report.write("{:^32} {:^27} \n".format(predicted_pedestrians, groundtruth_pedestrians))    
        report.write("Pedestrians bboxes were compared:")
        report.write("{:^15} {:^42} \n".format(predicted_processed_count, gt_processed_count))
        report.write("-" * 80 + "\n")

        report.write("Images were processed count: {} \n".format(processed_lables_count))
        report.write("Successfull detects: {} \n".format(predict_true))
        report.write("Intersection over Union threshold: {}% \n".format(iou_thr))
        report.write("Precision: {:.5} \n".format(precision))
        report.write("Recall: {:.5} \n".format(recall))
        report.write("-" * 80 + "\n")

        report.write("Plot of centres for pedestrians bboxes: 'centres.png'\n")        
        report.write("-" * 80 + "\n")
        
        report.write("Processing time: %.2f sec" %  (stop_time - start_time))   

    pr_data.close()
    gt_data.close()
    plt.savefig("centres.png")
    plt.show()