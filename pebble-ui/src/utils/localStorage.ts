import { BigNumber } from "ethers";

export interface GroupLocalStorage {
    [signerPublicAddress: string]: { // Checksummed address
        [groupId: string]: string // Maps group id to private key for the group
    }
}

/**
 * @dev Reads group data from local storage for a given signer
 * @param signerPublicAddress Public address of the current user
 */
export function getGroupsFromLocalStorage(signerPublicAddress: string) {
    const groupsMapString = window.localStorage.getItem("groupsMap");

    // If mapping exists
    if (typeof groupsMapString === "string") {
        const groupsMap = (JSON.parse(groupsMapString) as GroupLocalStorage)[signerPublicAddress];
        return groupsMap;
    } else { // If mapping does not exist
        return {}
    }
}

/**
 * @dev Sets group data from local storage for a given signer, group id and private key for creator
 * @param signerPublicAddress Public address of the current user
 * @param groupId Group ID of the group whose data to set
 * @param privateKeyForGroup Private key for the group for the current user
 */
export function setGroupInLocalStorage(signerPublicAddress: string, groupId: BigNumber, privateKeyForGroup: BigNumber) {
    const groupsMapString = window.localStorage.getItem("groupsMap");

    // If mapping exists
    let groupsMapNew: GroupLocalStorage;
    if (typeof groupsMapString === "string") {
        const groupsMapOld = (JSON.parse(groupsMapString) as GroupLocalStorage);
        const groupsForSigner = groupsMapOld[signerPublicAddress] ?? {};
        groupsMapNew = {
            ...groupsMapOld,
            [signerPublicAddress]: {
                ...groupsForSigner,
                [groupId.toString()]: privateKeyForGroup.toString()
            }
        }

    } else { // If mapping does not exist
        groupsMapNew = {
            [signerPublicAddress]: {
                [groupId.toString()]: privateKeyForGroup.toString()
            }
        }
    }

    // Set in local storage
    window.localStorage.setItem("groupsMap", JSON.stringify(groupsMapNew));
}