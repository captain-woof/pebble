import dayJs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import { utils } from "ethers";

dayJs.extend(relativeTime);

/**
 * @dev Shortens an address for display purposes
 * @param address Address to shorten
 * @returns Shortened address
 */
export function shortenAddress(address: string) {
    const addressChecksummed = utils.getAddress(address);
    const firstPart = addressChecksummed.slice(0, 6);
    const lastPart = addressChecksummed.slice(addressChecksummed.length - 2, addressChecksummed.length);
    return `${firstPart}...${lastPart}`;
}

/**
 * @dev Converts unix secs to humand readable format
 * @param unixSecs Time in Unix secs
 * @returns Human readable format (Date & time)
 */
export function convertUnixSecsToHumanFormatDateTime(unixSecs: string) {
    return dayJs.unix(parseInt(unixSecs)).format("D MMM, YYYY; hh:mm a");
}

/**
 * @dev Converts unix secs to humand readable format
 * @param unixSecs Time in Unix secs
 * @returns Human readable format (Date)
 */
export function convertUnixSecsToHumanFormatDate(unixSecs: string) {
    return dayJs.unix(parseInt(unixSecs)).format("D MMM, YYYY");
}

/**
 * @dev Converts unix secs to humand readable format
 * @param unixSecs Time in Unix secs
 * @returns Human readable format (Time)
 */
export function convertUnixSecsToHumanFormatTime(unixSecs: string) {
    return dayJs.unix(parseInt(unixSecs)).format("hh:mm a");
}

/**
 * @dev Converts unix secs to duration from now
 * @param unixSecs Time in Unix secs
 * @returns Duration from current time
 */
export function convertUnixSecsToTimeFromNow(unixSecs: string) {
    return dayJs.unix(parseInt(unixSecs)).fromNow(false);
}