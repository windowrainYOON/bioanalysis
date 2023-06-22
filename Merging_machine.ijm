macro "Merge Machine" {
	inputRed = getDirectory("home");
	inputGreen = getDirectory("home");
	inputBlue = getDirectory("home");
	inputR = getDirectory("home");
	isRed = false;
	isGreen = false;
	isBlue = false;
	Ch1Min = 0; //Red channel의 Bright & Constrast 최소값
	Ch1Max = 255; //Red channel의 Bright & Constrast 최대값
	Ch2Min = 0; //Green channel의 Bright & Constrast 최소값
	Ch2Max = 120; //Green channel의 Bright & Constrast 최대값
	Ch3Min = 30; //Blue channel의 Bright & Constrast 최소값
	Ch3Max = 162; //Blue channel의 Bright & Constrast 최대값
	suffix = "czi"; //분석할 파일의 확장자명
	saveSuffix = "tif"; //내보낼 파일의 확장자명
	Dialog.create("Particle Analysis");
	Dialog.addDirectory("Red channel folder path", inputRed);
	Dialog.addDirectory("Green channel folder path", inputGreen);
	Dialog.addDirectory("Blue channel folder path", inputBlue);
	Dialog.addDirectory("*Result folder path", inputR);
	Dialog.addCheckbox("Red", isRed);
	Dialog.addCheckbox("Green", isGreen);
	Dialog.addCheckbox("Blue", isBlue);
	Dialog.addSlider("Red min", 0, 255, Ch1Min);
	Dialog.addSlider("Red max", 0, 255, Ch1Max);
	Dialog.addSlider("Green min", 0, 255, Ch2Min);
	Dialog.addSlider("Green max", 0, 255, Ch2Max);
	Dialog.addSlider("Blue min", 0, 255, Ch3Min);
	Dialog.addSlider("Blue max", 0, 255, Ch3Max);
	Dialog.addString("Suffix for Import", suffix);
	Dialog.addString("Suffix for Export", saveSuffix);
	Dialog.show();
	
	inputRed = Dialog.getString();
	inputGreen = Dialog.getString();
	inputBlue = Dialog.getString();
	output = Dialog.getString();
	isRed = Dialog.getCheckbox();
	isGreen = Dialog.getCheckbox();
	isBlue = Dialog.getCheckbox();
	Ch1Min = Dialog.getNumber();
	Ch1Max = Dialog.getNumber();
	Ch2Min = Dialog.getNumber();
	Ch2Max = Dialog.getNumber();
	Ch3Min = Dialog.getNumber();
	Ch3Max = Dialog.getNumber();
	suffix = Dialog.getString();
	saveSuffix = Dialog.getString();
	
	
	//autothreshold = true; 
	
	
	print("initiating colocalization calulator macro...");
	run("Clear Results");
	run("Bio-Formats Macro Extensions");
	setOption("ExpandableArrays", true);
	
	
	inputs = newArray(isRed, isGreen, isBlue);
	channels = newArray(inputRed, inputGreen, inputBlue);
	minbnc = newArray(Ch1Min, Ch2Min, Ch3Min);
	maxbnc = newArray(Ch1Max, Ch2Max, Ch3Max);

	processPath(channels, output, inputs);
	
	function processPath(pathArray, resultPath, refArray) {
		waitForUser("Do not click elsewhere during the program is running...");
		File.makeDirectory(resultPath + "Merged");
		filePathArray = newArray(1);
		arrayNum = 0;
		for (n = 0; n < refArray.length; n++) {
			if (refArray[n] != 1) {
				n++;
				};
			if (refArray[n] == 1) {
				File.makeDirectory(resultPath + "Channel" + n+1);
				filePathArray[arrayNum] = pathArray[n];
				arrayNum++;
				};
			};
		if (filePathArray.length == 2) {
			processTwoFolder(filePathArray, refArray);
			};
		if (filePathArray.length == 3) {
			processThreeFolder(filePathArray, refArray);
			};
		};

	function processTwoFolder(pathList, refArray) { 
		list1 = getFileList(pathList[0]);
		Array.sort(list1);
		list2 = getFileList(pathList[1]);
		Array.sort(list2);
		if (list1.length == list2.length) {
			for (i = 0; i < list1.length; i++) {
				if(endsWith(list1[i], suffix)) {
					fileList = newArray(list1[i], list2[i]);
					processFile(pathList, fileList, refArray, output); //개별 이미지에 대한 프로세스
					};
				else {
					i++;
					};
				};
			};
		if (list1.length != list2.length) {
			print("please align the data pair."); //각 channel 별로 이미지가 짝이 지어져 있지 않은 경우
			};
		run("Clear Results");
		print("Processing finished");
		};
		
	function processThreeFolder(pathList, refArray) { 
		list1 = getFileList(pathList[0]);
		list2 = getFileList(pathList[1]);
		list3 = getFileList(pathList[2]);
		Array.sort(list1);
		Array.sort(list2);
		Array.sort(list3);
		if (list1.length == list2.length && list1.length == list3.length) {
			for (it = 0; it < list1.length; it++) {
				if(endsWith(list1[it], suffix)) {
					fileList = newArray(list1[it], list2[it], list3[it]);
					processFile(pathList, fileList, refArray, output); //개별 이미지에 대한 프로세스
					};
				else {
					it++;
					};
				};
			};
		if (list1.length != list2.length || list1.length != list3.length) {
			print("please align the data pair."); //각 channel 별로 이미지가 짝이 지어져 있지 않은 경우
			};
		run("Clear Results");
		run("Close All");
		print("Processing finished");
		};
		
		
	
	function processFile(pathList, inputFileList, refArray, outputPath) {
		run("Close All");
		
		//processing merging commend
		mergingSpell = "";
		printingSpell = "";
		t = 0;
		mergedFileName = "";
		
		locationList = newArray(3);
		for (m = 0; m < refArray.length; m++) {
			if(refArray[m] == 1) {
				applynum = m+1;
				spellAdd = "c" + applynum + "=" + inputFileList[t] + " ";
				printingSpell += inputFileList[t] + "/ ";
				mergingSpell += spellAdd;
				mergedFileName += inputFileList[t] + "+";
				//=====
				// process each images
				locationList[m] = pathList[t] + inputFileList[t];
				Ext.openImagePlus(locationList[m]);
				setOption("ScaleConversions", true);
				run("RGB Color");
				setMinAndMax(minbnc[m], maxbnc[m]);
				run("Apply LUT");
				t++;
				};
			};
		mergedFileName += "_Merged";
		
		print("Merging...");
		Array.print(inputFileList);
		
		
		
		//Merging
		run("Merge Channels...", mergingSpell + "create"); //c1 = red, c2 = green, c3 = blue
		selectWindow("Composite");
		saveAs(saveSuffix, outputPath + "Merged/" + mergedFileName);

		//save each file
		wait(1000);
		if (isOpen(mergedFileName + "." + saveSuffix)) {
			spliter(mergedFileName + "." + saveSuffix, outputPath, inputFileList, refArray);
			if (isOpen(mergedFileName + "." + saveSuffix)) {
				close(mergedFileName + "." + saveSuffix);
				};
			};
		};
		
		function spliter(windowName, savePath, saveNameArray, refArray) {
			selectWindow(windowName);
			run("Split Channels");
			wait(2000);
			d = 0;
			for (h = 0; h < refArray.length; h++) {
				openWindow = "C" + h+1 + "-" + windowName;
				if (refArray[h] != 0) {
					if (isOpen(openWindow)) {
						selectWindow(openWindow);
						saveAs(saveSuffix, savePath + "Channel" + h+1 + "/" + saveNameArray[d]);
						close();
						d++;
						};
					};
				if (refArray[h] == 0) {
					if (isOpen(openWindow)) {
						close(openWindow);
						};
					};
				};
			};
		
		
};