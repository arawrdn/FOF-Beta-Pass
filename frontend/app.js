import { createAppKit } from '@reown/appkit/ethers';
import { mainnet, base } from '@reown/appkit/networks';
import { ethers } from 'ethers';

const projectId = 'a5f9260bc9bca570190d3b01f477fc45';
const contractAddress = '0x757a025A78FAdE381EB8dd45cf991f97743Cb78c';
const abi = [
    "function mint(uint256 quantity) external payable",
    "function totalSupply() public view returns (uint256)",
    "function MINT_PRICE() public view returns (uint256)"
];

const metadata = {
    name: 'GM Builders Pass',
    description: 'FOF Beta Access Pass',
    url: 'https://fairlyoddfellas.com',
    icons: ['https://avatars.githubusercontent.com/u/177284434']
};

const modal = createAppKit({
    adapters: [], 
    networks: [base],
    metadata,
    projectId,
    features: { analytics: true }
});

let quantity = 1;
const mintBtn = document.getElementById('mint-btn');
const mintControls = document.getElementById('mint-controls');
const statusText = document.getElementById('status-mint');
const messageText = document.getElementById('message');

window.adjustQuantity = (val) => {
    quantity = Math.max(1, Math.min(2, quantity + val));
    document.getElementById('quantity').innerText = quantity;
};

async function updateStatus() {
    try {
        const provider = new ethers.JsonRpcProvider('https://mainnet.base.org');
        const contract = new ethers.Contract(contractAddress, abi, provider);
        const supply = await contract.totalSupply();
        statusText.innerText = `${supply} / 666`;
    } catch (e) { console.error(e); }
}

modal.subscribeAccount(state => {
    if (state.isConnected) {
        mintControls.classList.remove('hidden');
    } else {
        mintControls.classList.add('hidden');
    }
});

window.handleMint = async () => {
    try {
        const walletProvider = modal.getWalletProvider();
        if (!walletProvider) return;

        const ethersProvider = new ethers.BrowserProvider(walletProvider);
        const signer = await ethersProvider.getSigner();
        const contract = new ethers.Contract(contractAddress, abi, signer);

        const price = ethers.parseEther((0.00001 * quantity).toString());
        
        messageText.innerText = "Confirming in wallet...";
        const tx = await contract.mint(quantity, { value: price });
        
        messageText.innerText = "Transaction pending...";
        await tx.wait();
        
        messageText.innerText = "Successfully minted!";
        updateStatus();
    } catch (error) {
        messageText.innerText = error.reason || "Transaction failed";
        console.error(error);
    }
};

setInterval(updateStatus, 10000);
updateStatus();
