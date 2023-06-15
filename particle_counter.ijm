macro "puncta counting" {
	
	//이 부분을 수정해주세요
	input = "/Users/moonbi/Documents/files/document/문서v3/MGI/Data/immunofluorescence/230529 RUSH SCOTIN Time point condition/puncta cell count/230609 puncta cell count T-0/Green"; //분석할 폴더
	output = "/Users/moonbi/Documents/files/document/문서v3/MGI/Data/immunofluorescence/230529 RUSH SCOTIN Time point condition/puncta cell count/230609 puncta cell count T-0/Green/"; //내보낼 위치
	outputSummaryDataFileName = "analysis result";	//내보낼 파일의 이름
	outputResultDataFileName = "puncta properties";
	suffix = ".czi" //분석할 파일의 확장자명
	saveSuffix = "tif"
	
	bncMin = 20; //밝기 조정 min
	bncMax = 255; //밝기 조정 max
	minThreshold = 25; //minimum threshold
	maxThreshold = 255; //maximum threshold
	minParticle = 0.02; //particle size threshold, min (10 for DAPI)
	maxParticle = 5; //particle size threshold, max
	minCircularity = 0; //particle circularity, min
	maxCircularity = 1; //particle circularity, max
	//이 부분을 수정해주세요
	
	analysisProperty = "size=" + minParticle + "-" + maxParticle + "circularity=" + minCircularity + "-" + maxCircularity + "show=[Overlay Masks] display summarize";
	
	print("initiating puncta counting macro...");
	print("Target directory: " + input + "\n" + "Output data will save (overwrite) at: " + output + outputSummaryDataFileName + ".csv, " + outputResultDataFileName + ".csv" + "\n" + "Threshold: " + minThreshold + "-" + maxThreshold);
	run("Clear Results");
	run("Bio-Formats Macro Extensions");
	processFolder(input);
	
	function processFolder(input) {
		resultLocation = input + File.separator + "results";
		File.makeDirectory(resultLocation);
		list = getFileList(input);
		roiBoolean = getBoolean("Do you need ROI setting before analysis?");
		print(roiBoolean);
		for (i = 0; i < list.length; i++) {
			if(File.isDirectory(input + list[i]))
				processFolder("" + input + list[i]);
			if(endsWith(list[i], suffix))
				processFile(input, output, list[i], roiBoolean); //개별 이미지에 대한 프로세스
			else 
				i++;
			}
		selectWindow("Summary");
		saveAs("Results",  output + "/results/" + outputSummaryDataFileName + ".csv");
		selectWindow("Results");
		saveAs("Results",  output + "/results/" + outputResultDataFileName + ".csv");
		run("Clear Results");
		print("Data saved at" + output + "/results/" + outputSummaryDataFileName + ".csv");
		print("Data saved at" + output + "/results/" + outputResultDataFileName + ".csv");
		print("Processing finished");
		};
	
	
	function processFile(input, output, file, roiSet) {
		MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"); // Generate month names
		DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat"); // Generate date names
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec); // Get date and time information
		
		location = input + "/" + file;
		//fileItem = list[i] + " - C=0";
		fileItem = file;
		//open(location);
		Ext.openImagePlus(location);
		if (roiSet ==0) {
			setOption("ScaleConversions", true);
			run("8-bit");
			setMinAndMax(bncMin, bncMax);
			run("Apply LUT");
			setThreshold(minThreshold, maxThreshold, "raw");
			run("Analyze Particles...", analysisProperty); //particle property setting
			selectImage(fileItem);
			newName = fileItem + "_processed_" + i;
			saveAs(saveSuffix, input + "/results/" + newName);
		}
		if (roiSet == 1) {
			roiManager("reset");
			array1 = newArray("0"); 
			waitForUser("Drawing ROIs - Draw ROI, add to manager (command T on Mac). Draw ALL desired ROIs FIRST, then click OK to continue.");
			run("8-bit");
			setMinAndMax(bncMin, bncMax);
			run("Apply LUT");
			n = roiManager("count");
			for (i = 0; i < n; i++) {
			    roiManager("select", i);
			    // process roi here
				setThreshold(minThreshold, maxThreshold, "raw");
				run("Analyze Particles...", analysisProperty); //particle property setting
				selectImage(fileItem);
				newName = fileItem + "_processed_" + i;
				saveAs(saveSuffix, input + "/results/" + newName);
			}
			roiManager("reset");
		}

		close();
		print (DayNames[dayOfWeek], dayOfMonth, MonthNames[month], year + "," + hour + ":" + minute + ":" + second + ": Processing " + input + file);
		
		}
	
	};