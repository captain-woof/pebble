import dayJs from "dayjs";

/**
 * @dev Shortens an address for display purposes
 * @param address Address to shorten
 * @returns Shortened address
 */
export function shortenAddress(address: string) {
    const firstPart = address.slice(0, 6);
    const lastPart = address.slice(address.length - 2, address.length);
    return `${firstPart}...${lastPart}`;
}

export function convertUnixSecsToHumanFormat(unixSecs: string) {
    return dayJs.unix(parseInt(unixSecs)).format("D MMM, YYYY; hh:mm a");
}