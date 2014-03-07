########## ObjectUri ##########
objectID = getValue("ID")
if int(objectID) > 0 and int(getValue("ConstituentID")) == 1281:
    return "http://collection.britishart.yale.edu/id/" + objectID;
return "";
########## END ObjectUri END ##########

########## AcquisitionUri ##########
objectID = getValue("ID")
if int(objectID) > 0 and int(getValue("ConstituentID")) == 1281:
    return "http://collection.britishart.yale.edu/id/" + objectID + "/acquisition";
return "";
########## AcquisitionUri ##########

########## AcquisitionUri2 ##########
objectID = getValue("ID")
if int(objectID) > 0 and int(getValue("ConstituentID")) == 1281:
    return "http://collection.britishart.yale.edu/id/" + objectID + "/acquisition";
return "";
########## END AcquisitionUri2 END ##########

