﻿import { useState, useEffect, useContext, useRef } from 'react';
import { ChatContext } from '../ChatContext';
import { UserContext } from '../UserContext';
import Emote1 from '../Images/Calc Emote1.png';
import * as signalR from '@microsoft/signalr';
import IncomingMessage from '../Components/IncomingMessage.jsx';
import OutgoingMessage from '../Components/OutgoingMessage.jsx';
import EmojiEmotionsIcon from '@mui/icons-material/EmojiEmotions';
import SendIcon from '@mui/icons-material/Send';
import AddIcon from '@mui/icons-material/Add';
import AddLocationIcon from '@mui/icons-material/AddLocationAlt';
import InsertDriveFileIcon from '@mui/icons-material/InsertDriveFile';
import Emotes from '../Components/Emotes.jsx';
import RemoveIcon from '@mui/icons-material/Remove';
import CryptoJS from 'crypto-js';

const Chat = (props) => {
    const [messages, setMessages] = useState(null);
    const [user, setUser] = useState(JSON.parse(localStorage.getItem("user")));
    const [message, setMessage] = useState('');
    const [showEmojis, setShowEmojis] = useState(false);
    const [connection, setConnection] = useState(null);
    const { ChatID } = useContext(ChatContext);
    const [msgAttempt, setMsgAttempt] = useState(false);
    const [emote, setEmote] = useState([]);
    const [membersConnected, setMembersConnected] = useState([]);
    const fileInputRef = useRef(null);
    const [file, setFile] = useState(null);
    const [fileAttempt, setFileAttempt] = useState(false);
    const [idArchive, setIdArchive] = useState(null);
    const secretkey = 'my-very-secure-key-123';
    const [location, setLocation] = useState(false);

    const handleFileChange = (event) => {
        setFile(event.target.files[0]);
        if (file) {
            console.log("Archivo Seleccionado: " + file.name);
        }
    }

    const handleFileClick = () => {
        fileInputRef.current.click();
    }

    const handleLocationClick = () => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    console.log("Latitude: " + position.coords.latitude + ", Longitude: " + position.coords.longitude);
                },
                (error) => {
                    console.error("Error obtaining location: ", error);
                }
            );

            sendLocation();

        } else {
            console.error("Geolocation is not supported by this browser.");
        }
    }

    useEffect(() => {
        if (!msgAttempt) return;

        const nuevoMensaje = {
            usuarioEmisor: user.Matricula,
            chatReceptor: ChatID,
            mensaje: message,
            ID_Archivo: emote.EmoteID ? emote.EmoteID : idArchive,
            Encrypted: user.Encrypt,
            Location: location
        };

        const RegisterMessage = async () => {
            try {
                // Realiza la solicitud POST a la API
                const response = await fetch('Mensajes', {  //la path de la api (sin el controller)
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(nuevoMensaje),  // convierte el objeto a JSON (que es lo que espera la api)
                });

                const data = await response.json();
                //console.log(data);  // 
                if (!response.ok) {
                    throw new Error('Error en la solicitud');
                }
                setFile(null);
                setIdArchive(null);
                console.log('Mensaje registrado con éxito:', data);
            } catch (error) {
                console.error('Error al registrar el mensaje:', error);
            }
        }
        RegisterMessage();
        setMsgAttempt(false);
        setMessage("");
        setLocation(false);
        setFile(null);
    }, [msgAttempt, emote]);

    useEffect(() => {
        if (!fileAttempt) return;

        const fileReader = new FileReader();

        fileReader.readAsArrayBuffer(file);
        fileReader.onload = () => {
            const arrayBuffer = fileReader.result;
            const base64stringFile = btoa(new Uint8Array(arrayBuffer)
                .reduce((data, byte) => data + String.fromCharCode(byte), ""));

            const FileToUpload = {
                Nombre: file.name,
                MIMEType: file.type,
                tamano: file.size,
                Contenido: base64stringFile
            };

            const RegisterFile = async () => {
                try {
                    const response = await fetch('Archivos', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(FileToUpload),
                    });
                    const data = await response.json();
                    if (!response.ok) {
                        throw new Error("Error en la solicitud");
                    }
                    setIdArchive(data.iD_Archivo);
                    console.log(idArchive);
                    setFileAttempt(false);
                    console.log("Archivo registrado con exito: " + data);
                }
                catch (error) {
                    console.log("Eror al registrar archivo: " + error);
                }
            }
            RegisterFile();
        }
    }, [fileAttempt])

    useEffect(() => {
        props.onMembersConnected(membersConnected);
    }, [membersConnected]);

    useEffect(() => {
        if (!ChatID) return;
        setMessages([]);
        setMembersConnected([]);
        fetch('Mensajes?ID_Chat=' + ChatID).
            then(response => response.json()).
            then(data => {
                const RestructuredMessage = data.map(item => {
                    if (item.encrypted) {
                        item.mensaje = decryptMessage(item.mensaje, secretkey);
                    }
                    return ({
                        message: item.mensaje,
                        sender: item.usuarioEmisor,
                        type: item.usuarioEmisor === user.UserName ? "outcoming" : "incoming",
                        DateSent: item.fechaEnvio,
                        Archive: item.archivo,
                        userFoto: item.userFoto,
                        Location: item.location
                    })
                });
                setMessages(RestructuredMessage);
            });

        const connection = new signalR.HubConnectionBuilder()
            .withUrl("/chatHub", {
                withCredentials: true,
                queryParams: { Matricula: user.Matricula, chatID: ChatID },
            })
            .withAutomaticReconnect()
            .build();

        connection.start()
            .then(async () => {
                console.log("Connected to SignalR hub");
                setConnection(connection);

                if (ChatID) {
                    await connection.invoke("JoinChat", ChatID.toString(), user.Matricula);
                }
            })
            .catch(err => console.error("SignalR connection error: ", err));

        connection.on("UserConnected", (Matricula) => {
            console.log("This User Is Connected", Matricula);
            setMembersConnected(Matricula);
        });

        connection.on("UpdateActiveUsers", (activeUsers) => {
            console.log(activeUsers);
            setMembersConnected(activeUsers);
        });

        connection.on("UserDisconnected", (Matricula) => {
            console.log("Este user se salio gg", Matricula);
        });

        connection.on("ReceiveMessage", (sender, receivedMessage, ArchiveSent, DateOfSent, FotoUser, Encrypted, location) => {
            if (Encrypted) {
                receivedMessage = decryptMessage(receivedMessage, secretkey);
            }
            console.log(ArchiveSent);
            setMessages(prevMessages => [...prevMessages, { DateSent: DateOfSent, message: receivedMessage, sender, type: sender === user.UserName ? "outcoming" : "incoming", Archive: ArchiveSent, userFoto: FotoUser, Location: location }]);
        });

        return () => {
            connection.stop();
        };
    }, [ChatID]);

    useEffect(() => {
        if (idArchive) {
            sendMessageWithFile();
        }
    }, [idArchive]);

    const sendEmote = async (ArchiveSent) => {
        if (connection && !message)
            try {
                setMsgAttempt(true);
                await connection.invoke('SendMessage', user.UserName, message, ArchiveSent.EmoteID, ChatID.toString(), user.Matricula, false, false);
                setMessage("");
            } catch (err) {
                console.log("Mamaste: " + err);
            }
    }

    const sendMessageWithFile = async () => {
        if (connection && (message || file)) {
            try {
                console.log(file);
                console.log(idArchive);
                let FinalMessage = message;
                if (user.Encrypt) {
                    FinalMessage = encryptMessage(message, secretkey);
                    setMessage(FinalMessage);
                }
                await connection.invoke('SendMessage', user.UserName, FinalMessage, idArchive, ChatID.toString(), user.Matricula, user.Encrypt, false);
                setMsgAttempt(true);
            } catch (err) {
                console.log("Mamaste: " + err);
            }
        }
    };

    const sendLocation = async () => {
        navigator.geolocation.getCurrentPosition((position) => {
            const latitude = position.coords.latitude;
            const longitude = position.coords.longitude;
            setMessage(`https://www.google.com/maps/@${latitude},${longitude},15z`);
            setLocation(true);
            setMsgAttempt(true);
            connection.invoke('SendLocation', user.UserName, `https://www.google.com/maps/@${latitude},${longitude},15z`, ChatID.toString(), user.Matricula);
        });
    }

    const sendMessage = async () => {
        if (file) {
            console.log(file);
            setFileAttempt(true);
        }
        else {
            sendMessageWithFile();
        }
    }

    const encryptMessage = (message, key) => {
        return CryptoJS.AES.encrypt(message, key).toString();
    };

    const decryptMessage = (encryptedMessage, key) => {
        const bytes = CryptoJS.AES.decrypt(encryptedMessage, key);
        return bytes.toString(CryptoJS.enc.Utf8);
    };

    const handleEnter = async (event) => {
        if (event.key == 'Enter') {
            setEmote([]);
            sendMessage();
        }
    };

    const handleEmote = (data) => {
        setMessage("");
        setEmote(data);
        sendEmote(data);
    }
    const removeFile = () => {
        setFile(null);
        fileInputRef.current.value = "";
    }

    return (
        <div className="flex flex-col w-full h-full overflow-y-scroll">
            <div id="Messages-Container" className="flex flex-col w-full h-full overflow-y-scroll overflow-x-hidden">
                {messages && messages.map((msg, index) => (
                    msg.type === "incoming" ?
                        (<IncomingMessage key={index} message={msg.message} sender={msg.sender} DateSent={msg.DateSent} Archive={msg.Archive} userFoto={msg.userFoto} location={ msg.Location } />) :
                        (<OutgoingMessage key={index} message={msg.message} sender={msg.sender} DateSent={msg.DateSent} Archive={msg.Archive} userFoto={msg.userFoto} location={ msg.Location } />)
                ))}
            </div>
            {file && (
                <div className="flex">
                    <div className="flex bg-comp-1 rounded-sm p-2 items-center">
                        <InsertDriveFileIcon className="text-color" />
                        <p className="text-color font-bold text-sm">{file.name}</p>
                        <button className="text-xs" onClick={removeFile}><RemoveIcon /> </button>
                    </div>
                </div>
            )}
            <div id="MessageInput-Container" className="flex h-[5%] justify-center items-center space-x-2">
                <div id="btn-container" className="">
                    <input type="file" className="hidden" ref={fileInputRef} onChange={handleFileChange}></input>
                    <button id="AddFile"><AddIcon className="text-primary" onClick={handleFileClick} /></button>
                </div>
                <div id="btn-container" className="">
                    <button id="SendLocation"><AddLocationIcon className="text-primary" onClick={handleLocationClick} /></button>
                </div>
                <div className='btn-container'>
                    <button onClick={() => { setShowEmojis(!showEmojis) }} id="Emojis"><EmojiEmotionsIcon className="Icon-container text-primary" /></button>
                </div>
                <div className="w-full">
                    <input type="text" onKeyDown={handleEnter} className="w-full bg-transparent border-b-2 border-[var(--primary-color)] text-white outline-none" id="Message" value={message} onChange={(e) => setMessage(e.target.value)}></input>
                </div>
                <div className='btn-container'>
                    <button onClick={() => { sendMessage() }} id="SendMessage"><SendIcon className="Icon-container text-primary" /> </button>
                </div>
            </div>
            <Emotes show={showEmojis} EmoteSent={handleEmote} />
        </div>
    );
};

export default Chat;