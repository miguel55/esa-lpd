# ESA-LPD

## Description
This repository contains the code and documentation to implement the license plate detector described [here](https://ieeexplore.ieee.org/document/8437177/) :

```
Efficient Scale-Adaptive License Plate Detection System,
Miguel Molina-Moreno, Iván González Díaz and Fernando Díaz de María
IEEE Transactions on Intelligent Transportation Systems, 2018
```

This code is based on the implementation by [Antonio Torralba](http://web.mit.edu/torralba/www/) et al.
made available [here](http://people.csail.mit.edu/torralba/shortCourseRLOC/boosting/boosting.html).

## License

ESA-LPD code is released under the GNU GPLv3 License (refer to the `LICENSE` and `COPYING` files for details).

## Citing ESA-LPD

If you find ESA-LPD useful in your research, please consider citing:

	@ARTICLE{esalpd,
		author = {Efficient Scale-Adaptive License Plate Detection System},
		title = {Miguel Molina-Moreno, Iv\'an Gonz\'alez D\'iaz y Fernando D\'iaz de Mar\'ia},
		journal = {IEEE Transactions on Intelligent Transportation Systems},
		year = {2018},
		volume={},
		number={},
		pages={1-13},
		doi={10.1109/TITS.2018.2859035},
		ISSN={1524-9050}
	}

## Dependencies

ESA-LPD requires the following modules:

* [LabelMe](https://github.com/CSAILVision/LabelMeToolbox) - LabelMe toolbox
* [PASCAL VOC annotation tool](http://host.robots.ox.ac.uk/pascal/VOC/PAScode.tar.gz) - extra MatConvNet layers
* [VLFeat](https://github.com/vlfeat/vlfeat) - VLFeat libray


## Demo

Adjust the paths and parameters in `initPath.m` and `parameters.m` and run the file `main.m`. If you want to use a pre-trained detector, adjust the database in `parameters.m` and run the file `runDetector.m`.

A comparison of the mean AP of the pre-trained detectors is summarized below. The following numbers were obtained from a single run of the implementation (there may be some variance if repeated):

| BBDD           |     AP (%)  |  
|----------------|-------------|
| OS             |     97.52   |  
| Stills&Caltech |     99.41   |  
| AOLP           |     98.29   |  


## Installation

To start using ESA-LPD as a MATLAB toolbox, download and unzip this repository
```
git clone https://github.com/miguel55/esa-lpd
```

## More info

See `doc\documentation.tex` for more details.

