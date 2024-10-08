import {
  AddressLike,
  BigNumberish,
  Contract,
  WebSocketProvider,
  formatEther,
  Wallet,
  JsonRpcProvider,
} from "ethers";
import { Bridge__factory } from "./typechain-types";
import * as dotenv from "dotenv";

dotenv.config();

const sepoliaProvider = new WebSocketProvider(
  process.env.SEPOLIA_WS_RPC_URL as string, // Ensure the type is string
  {
    name: "sepolia",
    chainId: 11155111,
  },
);

const sepoliaBridgeContract = new Contract(
  process.env.SEPOLIA_BRIDGE_ADDRESS as string, // Make sure this is set in your .env
  Bridge__factory.abi,
  sepoliaProvider,
);

console.log("bot listening!");

sepoliaBridgeContract.on(
  "Deposit",
  async (depositor: AddressLike, amount: BigNumberish) => {
    const provider = new JsonRpcProvider(process.env.BINANNCE_RPC_URL as string, {
      name: "binance",
      chainId: 97,
    });
    const sender = new Wallet(process.env.PRIVATE_KEY as string, provider);
    const bridge = Bridge__factory.connect(
      process.env.BINANNCE_BRIDGE_ADDRESS as string, // Make sure this is also set in your .env
      sender,
    );
    console.log(`Sending ${formatEther(amount)} tokens to ${depositor}`);
    await bridge.release(depositor, amount);
    console.log(
      `Sent ${formatEther(amount)} tokens to ${depositor} on Mumbai contract: ${process.env.BINANNCE_BRIDGE_ADDRESS}`
    );
  },
);
