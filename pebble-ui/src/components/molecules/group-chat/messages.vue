<script setup lang="ts">
import { ref, watch } from "vue";
import usePebbleStore from "@store/pebble";
import { decryptMessageWithSharedKey, convertHexToBase64 } from "@pebble/sdk";
import useWalletStore from "@store/wallet";
import { utils } from "ethers";
import { convertUnixSecsToHumanFormat } from "@utils/string";

// Interface
interface IMessagesPlainText {
    id: string;
    messageEnc: string;
    sender: string;
    timestamp: string;
    messagePlaintext: string;
    own: boolean;
}

// States
const walletStore = useWalletStore();
const pebbleStore = usePebbleStore();
const sendingMessage = ref(false);
const messageToSend = ref("");
const messagesForDisplay = ref<Array<IMessagesPlainText>>([]);
const autoScroll = ref(true);

// Watchers
watch(() => pebbleStore.groupSelected?.messages, (messagesEncNew, messagesEncPrev) => {
    messagesEncNew = messagesEncNew ?? [];
    messagesEncPrev = messagesEncPrev ?? [];

    const messagesToPush = messagesEncNew
        .slice(messagesEncPrev.length)
        .map((messageEnc) => ({
            ...messageEnc,
            sender: utils.getAddress(messageEnc.sender),
            messagePlaintext: decryptMessage(messageEnc.messageEnc),
            own: walletStore.account?.address === utils.getAddress(messageEnc.sender),
            timestamp: convertUnixSecsToHumanFormat(messageEnc.timestamp)
        }));

    if (messagesToPush.length !== 0) {
        messagesForDisplay.value.push(...messagesToPush);
    }
}, { immediate: true, deep: true });


function scrollLastMessageIntoView() {
    if (autoScroll.value) {
        document.querySelector(".messages__list__message--last")?.scrollIntoView({ behavior: "smooth" });
    }
}

function decryptMessage(messageEnc: string) {
    if (pebbleStore.groupSelectedSharedKey) {
        const messageEncBase64 = convertHexToBase64(messageEnc);
        const messagePlaintext = decryptMessageWithSharedKey(messageEncBase64, pebbleStore.groupSelectedSharedKey);
        return messagePlaintext !== "" ? messagePlaintext : "Could not decrypt!";
    } else {
        return "Could not decrypt!";
    }
}

async function handleSendMessage() {
    try {
        sendingMessage.value = true;
        await pebbleStore.sendMessage(messageToSend.value);
        messageToSend.value = "";
    } catch (error) {

    } finally {
        sendingMessage.value = false;
    }
}
</script>

<template>
    <div class="messages w-100 px-2 px-sm-4">
        <!-- Heading -->
        <h1 class="text-h5">
            Group #{{ pebbleStore.groupSelected?.id }}
        </h1>

        <!-- Messages list -->
        <div class="messages__list w-100" @scroll="handleMessagesScroll">
            <div v-for="(messageForDisplay, i) in messagesForDisplay"
                class="messages__list__message mb-4 bg-background-elevated px-4 py-2 rounded-lg"
                :class="{ 'messages__list__message--own': messageForDisplay.own, 'messages__list__message--last': i === messagesForDisplay.length - 1 }"
                :key="messageForDisplay.id">
                <!-- Title -->
                <h1 class="text-caption messages__list__message__title">
                    {{ messageForDisplay.own ? "You" : messageForDisplay.sender }}
                </h1>

                <!-- Text -->
                <p class="text-body-1 messages__list__message__text">
                    {{ messageForDisplay.messagePlaintext }}
                </p>

                <!-- Timestamp -->
                <p class="text-caption mt-1 d-block ml-auto messages__list__message__timestamp">
                    {{ messageForDisplay.timestamp }}
                </p>
            </div>
        </div>

        <!-- Type message -->
        <v-text-field class="messages__input w-100 mt-4" v-model="messageToSend" autofocus active
            append-inner-icon="mdi-send" :loading="sendingMessage" :disabled="sendingMessage"
            placeholder="Type your message..." variant="solo" @click:append-inner="handleSendMessage" hide-details
            single-line></v-text-field>
    </div>
</template>

<style lang="scss" scoped>
.messages {
    height: 100%;
    width: 100%;
    position: relative;
    display: flex;
    flex-direction: column;

    .messages__list {
        flex-grow: 1;
        overflow-y: auto;
        display: flex;
        flex-direction: column;

        .messages__list__message {

            &--own {
                margin-left: auto;
            }

            .messages__list__message__timestamp {
                width: fit-content;
            }
        }
    }

    .messages__input {
        flex-grow: 0;
    }
}
</style>