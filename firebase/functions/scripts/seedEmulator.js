/**
 * 에뮬레이터 Firestore에 "다른 사람이 만든 약속"을 넣는다 — 계정 하나로 코드 참여를 확인하기 위한 테스트 데이터.
 * 더미 사용자 2명이 참여한 약속과 코드 예약(DUMMY2)을 만든다. 다시 실행하면 처음 상태로 되돌린다.
 * UID를 넘기면 그 계정이 더미 사용자 2명과 함께 참여한 오늘·예정·지난 약속도 만든다 — 목록 화면 확인용.
 * 실행: npm run seed [-- <내 UID>] (에뮬레이터가 켜져 있어야 한다. UID 계정은 앱에서 로그인해 users 문서가 있어야 한다)
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
const PLACE = {
  id: "place_starbucks_gangnam",
  name: "스타벅스 강남역점",
  address: "서울 강남구 강남대로 396",
  coordinate: {latitude: 37.4979, longitude: 127.0276},
  type: "CAFE",
};
const HOUR = 60 * 60 * 1000;
const DAY = 24 * HOUR;

async function seed() {
  const userID = process.argv[2];
  if (userID) {
    await requireUser(userID);
  }

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
    dateTime: Timestamp.fromMillis(Date.now() + DAY),
    place: PLACE,
    participantIDs: DUMMY_USERS.map(({id}) => id),
  });

  batch.set(db.collection("appointmentCodes").doc(CODE), {appointmentID: APPOINTMENT_ID});

  const myAppointments = userID ? makeMyAppointments() : [];
  myAppointments.forEach(({id, code, name, dateTimeMillis}) => {
    batch.set(db.collection("appointments").doc(id), {
      name,
      code,
      dateTime: Timestamp.fromMillis(dateTimeMillis),
      place: PLACE,
      participantIDs: [userID, ...DUMMY_USERS.map((user) => user.id)],
    });
    batch.set(db.collection("appointmentCodes").doc(code), {appointmentID: id});
  });

  await batch.commit();
  console.log(`약속 "${APPOINTMENT_ID}" 생성 — 참여 코드 ${CODE}`);
  myAppointments.forEach(({name, code}) => console.log(`${name} 생성 — 코드 ${code}`));
}

/** UID를 잘못 넘겨 아무도 볼 수 없는 약속이 만들어지지 않도록 먼저 확인한다 */
async function requireUser(userID) {
  const user = await db.collection("users").doc(userID).get();
  if (!user.exists) {
    throw new Error(`users/${userID} 문서가 없습니다. 앱에서 로그인한 뒤 다시 실행하세요.`);
  }
}

/** 화면별 조회 범위의 안쪽과 바깥을 모두 확인하도록 시각을 나눈다 */
function makeMyAppointments() {
  const now = Date.now();
  // 자정이 가까워도 오늘 약속으로 남도록 오늘 안으로 제한한다
  const endOfToday = new Date(now).setHours(23, 59, 0, 0);

  return [
    {id: "test_today", code: "TESTA2", name: "[테스트] 오늘", dateTimeMillis: Math.min(now + HOUR, endOfToday)},
    {id: "test_upcoming", code: "TESTB2", name: "[테스트] 예정", dateTimeMillis: now + 3 * DAY},
    {id: "test_past", code: "TESTC2", name: "[테스트] 지난 약속", dateTimeMillis: now - 3 * DAY},
    {id: "test_expired", code: "TESTD2", name: "[테스트] 30일 넘게 지남", dateTimeMillis: now - 31 * DAY},
  ];
}

seed().catch((error) => {
  console.error("시드 실패 — 에뮬레이터가 켜져 있는지 확인하세요.", error.message);
  process.exit(1);
});
