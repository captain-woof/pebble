import dayJs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";

dayJs.extend(relativeTime);

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

/**
 * @dev Converts unix secs to humand readable format
 * @param unixSecs Time in Unix secs
 * @returns Human readable format
 */
export function convertUnixSecsToHumanFormat(unixSecs: string) {
    return dayJs.unix(parseInt(unixSecs)).format("D MMM, YYYY; hh:mm a");
}

/**
 * @dev Converts unix secs to duration from now
 * @param unixSecs Time in Unix secs
 * @returns Duration from current time
 */
export function convertUnixSecsToTimeFromNow(unixSecs: string) {
    return dayJs.unix(parseInt(unixSecs)).fromNow(false);
}