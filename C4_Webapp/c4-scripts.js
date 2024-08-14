function createWallet() {
    fetch('/api/wallet/create', {
        method: 'POST',
    })
    .then(response => response.json())
    .then(data => {
        alert('Wallet erstellt: ' + data.walletId);
    })
    .catch(error => {
        console.error('Error:', error);
    });
}

function encryptFile() {
    const filePath = document.getElementById('file-path').value;
    fetch('/api/encrypt', {
        method: 'POST',
        body: JSON.stringify({ path: filePath }),
    })
    .then(response => response.json())
    .then(data => {
        alert('Datei verschlüsselt: ' + data.status);
    })
    .catch(error => {
        console.error('Error:', error);
    });
}
