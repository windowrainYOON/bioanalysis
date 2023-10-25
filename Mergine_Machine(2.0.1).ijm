macro "Merging Machine" {
	input = getDirectory("home");
	isMerge = true;
	isMarker = true;
	Ch1Min = 0; //Red channel의 Bright & Constrast 최소값
	Ch1Max = 255; //Red channel의 Bright & Constrast 최대값
	Ch2Min = 0; //Green channel의 Bright & Constrast 최소값
	Ch2Max = 255; //Green channel의 Bright & Constrast 최대값
	Ch3Min = 0; //Blue channel의 Bright & Constrast 최소값
	Ch3Max = 255; //Blue channel의 Bright & Constrast 최대값
	Ch4Min = 0; //Blue channel의 Bright & Constrast 최소값
	Ch4Max = 255; //Blue channel의 Bright & Constrast 최대값
	Ch5Min = 0;
	Ch5Max = 255;
	markerSize = 20;
	suffix = "czi"; //분석할 파일의 확장자명
	saveSuffix = "tif"; //내보낼 파일의 확장자명
	
	
	Dialog.create("Merging Machine (2.0.0) - designed by C. Yoon");
	Dialog.addDirectory("Choose a folder to process", input);
	Dialog.addMessage("Settings for red channel: ", 15, "red");
	Dialog.addSlider("Red min", 0, 255, Ch1Min);
	Dialog.addSlider("Red max", 0, 255, Ch1Max);
	Dialog.addMessage("Settings for green channel: ", 15, "green");
	Dialog.addSlider("Green min", 0, 255, Ch2Min);
	Dialog.addSlider("Green max", 0, 255, Ch2Max);
	Dialog.addMessage("Settings for blue channel: ", 15, "blue");
	Dialog.addSlider("Blue min", 0, 255, Ch3Min);
	Dialog.addSlider("Blue max", 0, 255, Ch3Max);
	Dialog.addMessage("Settings for magenta channel: ", 15, "magenta");
	Dialog.addSlider("Magenta min", 0, 255, Ch4Min);
	Dialog.addSlider("Magenta max", 0, 255, Ch4Max);
	Dialog.addMessage("Settings for Bright Field channel: ", 15, "Black");
	Dialog.addSlider("BF min", 0, 255, Ch5Min);
	Dialog.addSlider("BF max", 0, 255, Ch5Max);
	
	Dialog.addCheckbox("Auto Merge", isMerge);
	Dialog.addCheckbox("Scale Bar (63x)", isMarker);
	Dialog.addSlider("Determine Scale Bar Size (μm)", 0, 200, markerSize);
	Dialog.addString("Suffix for Import", suffix);
	Dialog.addString("Suffix for Export", saveSuffix);
	
	Dialog.show();
	
	input = Dialog.getString();
	isMerge = Dialog.getCheckbox();
	isMarker = Dialog.getCheckbox();
	Ch1Min = Dialog.getNumber();
	Ch1Max = Dialog.getNumber();
	Ch2Min = Dialog.getNumber();
	Ch2Max = Dialog.getNumber();
	Ch3Min = Dialog.getNumber();
	Ch3Max = Dialog.getNumber();
	Ch4Min = Dialog.getNumber();
	Ch4Max = Dialog.getNumber();
	Ch5Min = Dialog.getNumber();
	Ch5Max = Dialog.getNumber();
	markerSize = Dialog.getNumber();
	suffix = Dialog.getString();
	saveSuffix = Dialog.getString();
	
	//autothreshold = true; 
	
	
	print("initiating merging machine macro...");
	run("Clear Results");
	run("Bio-Formats Macro Extensions");
	setOption("ExpandableArrays", true);
	
	colors = newArray("Red", "Green", "Blue", "Magenta", "Grays");
	files = getFileList(input);
	images = newArray(1);
	k = 0;
	for (i = 0; i < files.length; i++) {
		if(endsWith(files[i], suffix)) {
			images[k] = files[i];
			k++;
			};
		};
	Array.sort(images);
	
	function processPath (imageNames, inputPath) {
		imagePathArray = newArray(inputPath + "Processed/1)Red(560nm)", inputPath + "Processed/2)Green(495nm)", inputPath + "Processed/3)Blue(395nm)", inputPath + "Processed/4)Magenta(660nm)", inputPath + "Processed/5)BrightField");
		Array.sort(imagePathArray);
		File.makeDirectory(inputPath + "Processed");
		File.makeDirectory(imagePathArray[0]);
		File.makeDirectory(imagePathArray[1]);
		File.makeDirectory(imagePathArray[2]);
		File.makeDirectory(imagePathArray[3]);
		File.makeDirectory(imagePathArray[4]);
		print("Directory created in " + inputPath);
		for (n = 0; n < imageNames.length; n++) {
			run("Bio-Formats Importer", "open=[" + inputPath + imageNames[n] + "] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			Ext.setId(inputPath + imageNames[n]);
			Ext.getMetadataValue("Information|Instrument|Dichroic|Wavelength", value);
			print(imageNames[n], value + "nm");
			if (value == 560) {
				processImage (imageNames[n], imagePathArray[0], Ch1Max, Ch1Min, "Red");
				};
			if (value == 495) {
				processImage (imageNames[n], imagePathArray[1], Ch2Max, Ch2Min, "Green");
				};
			if (value == 395) {
				processImage (imageNames[n], imagePathArray[2], Ch3Max, Ch3Min, "Blue");
				};
			if (value == 660) {
				processImage (imageNames[n], imagePathArray[3], Ch4Max, Ch4Min, "Magenta");
				};
			if (value == 0) {
				processImage (imageNames[n], imagePathArray[4], Ch5Max, Ch5Min, "Grays");
				};
			};
		if (isMerge) {
			mergeImage(imagePathArray, inputPath);
			};
		waitForUser("Merging Machine", "Image Processing in <" + input + "> Completed.");
		print("Image Processing in <" + input + "> Completed.");
		};
	
	function processImage (name, path, maxBC, minBC, color) {
		setOption("ScaleConversions", true);
		run(color);
		run("RGB Color");
		setMinAndMax(minBC, maxBC);
		if (isMarker == 1) {
			run("Set Scale...", "distance=182.6667 known=10 unit=μm global");
			run("Scale Bar...", "width=" + markerSize + " height=2 thickness=10 font=25 bold");
			};
		saveAs(saveSuffix, path + "/" + name + "_saved");
		close();
		};
	
	function mergeImage (channelPathArray, initialPath) {
		File.makeDirectory(initialPath + "Processed/Merged");
		emptyColorIndex = newArray(1);
		filledFileIndex = newArray(1);
		l = 0;
		for (i = 0; i <= 4; i++) {
			imageFile = getFileList(channelPathArray[i]);
			imageCount = imageFile.length;
			if (imageCount == 0) {
				emptyColorIndex[i] = 0;
				};
			if (imageCount != 0) {
				emptyColorIndex[i] = 1;
				filledFileIndex[l] = channelPathArray[i];
				l++;
				};
			};
		
		processMergingImage (filledFileIndex, emptyColorIndex);
		};
	
	function processMergingImage (imageToMergePathArray, refArray) {
		fileCount = getFileList(imageToMergePathArray[0]);
		for (it = 0; it < fileCount.length; it++) {
			fileList = newArray(1);
			for (mer = 0; mer < imageToMergePathArray.length; mer++) {
				files = getFileList(imageToMergePathArray[mer]);
				fileList[mer] = files[it];
				};
			combineImage(imageToMergePathArray, fileList, refArray); //개별 이미지에 대한 프로세스
			};
		};
	
	function combineImage (savePath, finalImageToMergeArray, refArray) {
		run("Close All");
		//processing merging commend
		mergingSpell = "";
		printingSpell = "";
		t = 0;
		mergedFileName = "";
		
		locationList = newArray(3);
		for (m = 0; m < refArray.length; m++) {
			if(refArray[m] == 1) {
				if (m == 3) {
					applynum = 6;
					};
				else {
					applynum = m+1;
					};
				spellAdd = "c" + applynum + "=" + finalImageToMergeArray[t] + " ";
				printingSpell += finalImageToMergeArray[t] + "/ ";
				mergingSpell += spellAdd;
				mergedFileName += finalImageToMergeArray[t] + "+";
				locationList[m] = savePath[t] + "/" + finalImageToMergeArray[t];
				open(locationList[m]);
				t++;
				};
			};
		mergedFileName += "_Merged";
		print("Merging...");
		wait(200);
		Array.print(finalImageToMergeArray);
		run("Merge Channels...", mergingSpell + " keep");
		selectWindow("RGB");
		saveAs(saveSuffix, input + "Processed/Merged/" + mergedFileName);
		run("Close All");
		};
	
	
	processPath (images, input);
	
	
	};