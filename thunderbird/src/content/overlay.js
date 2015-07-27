var virgil = {

    onLoad: function() {
        // initialization code
        this.initialized = true;
        this.gfiltersimportexportBundle = Components.classes["@mozilla.org/intl/stringbundle;1"].getService(Components.interfaces.nsIStringBundleService);
        this.mystrings = this.gfiltersimportexportBundle.createBundle("chrome://{appname}/locale/overlay.properties");
    },

    onKeyringOpen: function() {
        alert("Need KeyRing Application");
    },

    onEMailSend: function() {
        alert("Send catched");
    },

    onSendMessage: function(originFunction) {
        var needEncrypt = false;
        try {
            var cbEncrypt = document.getElementById("virgil-button-encription");
            if (cbEncrypt.getAttribute("checked") == "true") {
                needEncrypt = true;
            }
        } catch (error) {}

        if (needEncrypt) {
            try {
                emailHelper.setDocument(document);
                var sender = emailHelper.sender();
                var receivers = emailHelper.receivers();
                var subject = emailHelper.subject();
                var body = emailHelper.body();
                var attachements = emailHelper.attachements();

                var info = "Encriprion data : \n";
                info += "sender: " + sender + "\n";
                info += "receivers: " + receivers + "\n";
                info += "subject: " + subject + "\n";
                info += "body: " + body + "\n";
                info += "attachements: " + attachements + "\n";

                alert(info);
            } catch (error) {
                alert("Can't encrypt data");
            }
        }

        originFunction();
    },

    getString: function(key) {
        try {
            var str = this.mystrings.GetStringFromName(key);
            return str;
        } catch (e) {
            return key;
        }
    },
};

// "onLoad" event doesn't work correctly
setTimeout(virgil.onLoad, 1000);

// Put handler for send button

///override the default SendMessage function from "MsgComposeCommands.js"
///SendMessage function gets called when you click the "Send" button
virgil.sendMessageOriginal = SendMessage;
var SendMessage = function() {
        virgil.onSendMessage(virgil.sendMessageOriginal);
    };

///override the default SendMessageWithCheck function from "MsgComposeCommands.js"
///SendMessageWithCheck function gets called when you use a keyboard shortcut,
///such as Ctl-Enter (default), to send the message
virgil.sendMessageWithCheckOriginal = SendMessageWithCheck;
var SendMessageWithCheck = function() {
        virgil.onSendMessage(virgil.sendMessageWithCheckOriginal);
    };

///override the default SendMessageLater function from "MsgComposeCommands.js"
///SendMessage function gets called when you choose "Send Later" command
virgil.sendMessageLaterOriginal = SendMessageLater;
var SendMessageLater = function() {
        virgil.onSendMessage(virgil.sendMessageLaterOriginal);
    }