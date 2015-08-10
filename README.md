## Mail encryption: ##

Encrypted mail consist of two parts

Html preview with encrypted recepients/signs data in #virgil-info input

	<html>
		<body>
			<p>The message has been encrypted with VirgilOutlook Add-In.</p>
			<a href='https://virgilsecurity.com/downloads/' >Download Virgil Outlook Add-In.</a>

			<input id='virgil-info' type='hidden' value='{0}' />

		</body>
	</html>

And encrypted mail attachments.


Virgil info contains base64 encoded string of a json serialized structure 

	{
		"EmailData" : "123abcd...", // base64 string of encrypted mail data
		"Sign" : "acdef12345..." // base64 string os sign of encrypted mail, created data with sender private key
	}

EmailData is encrypted json object of following structure

	{
		"UniqueId" : "", // guid string for salt
		"Body" : "", // plain text message body
		"HtmlBody" : "", // html representation
		"Subject" : "", // mail subject
	} 

Encryption: 

To encrypt email this steps are executed: 

1. Intercept mail send by mail client
2. Parse the list of recipients
3. Query Public Keys service to retrieve each recipient public key and public key id
4. Serialize EmailData object into json and encrypt it	
	1. Cipher object should be initialized with each recipient public key.
	2. Sender's key should be added to be able to decrypt sent mail
	3. EmailData is encrypted with embedContentInfo set to true
5. Encrypted MailData object then used as an input for a sign method as well as sender private key value
6. Each attachment is being scanned and replaced with its encrypted value, using same cipher.


Pseudo code:

	var cipher = new VirgilCipher()  
	
	// add all recepients
	foreach(var recepient in recepients) {
		cipher.AddKeyRecipient(recepient.publicKeyId, recepient.publicKey);
	}
	// add us
	cipher.AddKeyRecipient(sender.publicKeyId, sender.publicKey);
	// get email data
	var mailData = new CipherEmailData
	{
	    UniqueId = Guid.NewGuid().ToString(),
	    Body = mail.Body,
	    HtmlBody = mail.HTMLBody,
	    Subject = mail.Subject
	};
	// serialize and encrypt mail data
	var mailDataJson = JsonConvert.SerializeObject(mailData);
	byte[] encryptedMailData = cipher.Encrypt(mailDataJson);
	// encrypt attachemts
	foreach (var attachment in attachemnts)
	{   
	    attachment.Data = cipher.Encrypt(attachemnt.Data);    
	}
	// build message info and add sign 
	var mailInfo = new VirgilMessageInfo
	{
	    EmailData = encryptedMailData,
	    Sign = Signer.Sign(encryptedMailData, sender.PrivateKey)
	};
	
	// replace email text with html template containing mail data
	string mailInfoJson = JsonConvert.SerializeObject(mailInfo);
	byte[] encodedInfo = Convert.ToBase64(mailInfoJson);
		
	mail.HTMLBody = string.Format(HtmlBody, encodedInfo);

## Mail decryption ##

Steps to decrypt : 

1. Scan mail plain text for `<input id='virgil-info' type='hidden' value='{0}' />` and extact its value
2. Deserialize VirgilInfo
2. Verify sign with sender's public key
2. Decrypt EmailData with your private key
3. Deserialize EmailData
3. Decrypt attachments with your private key

Pseudocode:

	VirgilMessageInfo info = mail.ExtractHtmlNodeValue('#virgil-info');
	
	var senderPublicKey = PKI.GetPublicKey(mail.Sender);
	
	bool verified = Signer.Verify(info.EmailData, info.Sign, senderPublicKey);
	if (!verified)
		Abort();
	
	var cipher = new Cipher();
	ciper.DecryptWithKey(info.EmailData, ourPublicKeyId, ourPrivateKey);
	
	foreach (var attachment in attachemnts)
	{   
	    attachment.Data = cipher.Decrypt(attachemnt.Data, ourPublicKeyId, ourPrivateKey);    
	}

## Handling unregistered users: ## 

Currently for a recipient who's email is not registered on Public Key Service we send invitation instead of encrypted mail. Sender would have to resend email one more time to deliver it to the initial recipient.

In the case when some of the recipients are not registered adding send mail to available users, and sends invitation mail for unregistered ones. Display info message before mail send.

