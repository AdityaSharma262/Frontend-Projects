let qrImage = document.getElementById("qrImage");
let qrText = document.getElementById("qrText");
let imgBox = document.getElementById("imgBox");

function generateQr() {
    qrImage.src = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=" + qrText.value;
    
}

