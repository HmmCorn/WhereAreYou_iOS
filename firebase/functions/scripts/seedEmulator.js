/**
 * 에뮬레이터 Firestore에 "다른 사람이 만든 약속"을 넣는다 — 계정 하나로 코드 참여를 확인하기 위한 테스트 데이터.
 * 더미 사용자 2명이 참여한 약속과 코드 예약(DUMMY2)을 만든다. 다시 실행하면 처음 상태로 되돌린다.
 * 실행: npm run seed (에뮬레이터가 켜져 있어야 한다)
 */

// 실서버에 쓰지 않도록 에뮬레이터 주소를 강제한다
process.env.FIRESTORE_EMULATOR_HOST = "localhost:8080";

const {initializeApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");

initializeApp({projectId: "whereareyou-16ea6"});
const db = getFirestore();

const APPOINTMENT_ID = "dummy_appointment";
const CODE = "DUMMY2";
const DUMMY_USERS = [
  {id: "dummy_minji", nickname: "김민지", profileImage: "turtle", defaultTransportMode: "TRANSIT"},
  {id: "dummy_junwoo", nickname: "박준우", profileImage: "shark", defaultTransportMode: "CAR"},
];

async function seed() {
  const batch = db.batch();

  DUMMY_USERS.forEach(({id, ...profile}) => {
    batch.set(db.collection("users").doc(id), {
      ...profile,
      locationSharingScope: "ONLY_DURING_APPOINTMENT",
      isNotificationEnabled: true,
      appointmentsNotification: {},
    });
  });

  batch.set(db.collection("appointments").doc(APPOINTMENT_ID), {
    name: "더미 약속",
    code: CODE,
    // 내일 같은 시각
    dateTime: Timestamp.fromMillis(Date.now() + 24 * 60 * 60 * 1000),
    place: {
      id: "place_starbucks_gangnam",
      name: "스타벅스 강남역점",
      address: "서울 강남구 강남대로 396",
      coordinate: {latitude: 37.4979, longitude: 127.0276},
      type: "CAFE",
    },
    participantIDs: DUMMY_USERS.map(({id}) => id),
  });

  batch.set(db.collection("appointmentCodes").doc(CODE), {appointmentID: APPOINTMENT_ID});

  await batch.commit();
  console.log(`약속 "${APPOINTMENT_ID}" 생성 — 참여 코드 ${CODE}`);
}

seed().catch((error) => {
  console.error("시드 실패 — 에뮬레이터가 켜져 있는지 확인하세요.", error.message);
  process.exit(1);
});
