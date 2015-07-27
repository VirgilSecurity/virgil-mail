var emailHelper = {

    setDocument: function(doc) {
        this.document = doc;
        this.initDone = true;
    },

    sender: function() {
        if (this.initDone == false) return "";
        try {
            var res = this.document.getElementById("msgIdentity").label;
        } catch (error) {
            var res = "";
        }

        return res;
    },

    receivers: function() {
        if (this.initDone == false) return "";
        return "receivers";

        // TODO: Use field "textcol - addressingWidget"
    },

    subject: function() {
        if (this.initDone == false) return "";
        try {
            var res = this.document.getElementById("msgSubject").value;
        } catch (error) {
            var res = "";
        }

        return res;
    },

    body: function() {
        if (this.initDone == false) return "";
        try {
            var res = this.document.getElementById("content-frame").contentDocument.lastChild.lastChild.innerHTML;
        } catch (error) {
            var res = "";
        }

        return res;
    },

    attachements: function() {
        var res = [];
        if (this.initDone == false) return res;
        try {
            var bucketList = this.document.getElementById("attachmentBucket");
            var sXML = new XMLSerializer().serializeToString(bucketList);
            //alert(sXML);
            //if ((bucketList != null) && (bucketList.getRowCount() > 0)) {
            //    bucketList.forEach(function(item) {
            //        //alert(item);
            //    });
            //}
        } catch (error) {
            var res = [];
            alert("error");
        }

        return res;
    }
};