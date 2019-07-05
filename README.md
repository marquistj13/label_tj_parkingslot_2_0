# label_tj_parkingslot_2_0
label script and label results for Tongji Parking-slot Dataset 2.0

## Introduction
The original [Tongji Parking-slot Dataset 2.0](https://cslinzhang.github.io/deepps/) only include two corner points and the slot type for each parking slot.

This repo reuse sevral files from [DeepPSMat.zip](https://drive.google.com/open?id=1qPx33fYNY8MhX7hv8lNAHAhlP14aNoDJ) to extract the full corners (i.e., four corners) for each parking slot.

## How to use
* method 1
The label results is in `slot_results.zip`. I have extracted all the labels of the dataset for you.

* method 2
or you can extract the labels yourself: You only need to run `test.m` in matlab. 
>Of course you need to change the data directory in `test.m`.
__Requirement:__ only matlab is needed.
