import { useEffect, useState } from "react";
import { db } from "../lib/firebase";
import { ref, onValue, query, orderByChild, equalTo } from "firebase/database";

export interface BakatiketEvent {
  id: string;
  name: string;
  location: string;
  description: string;
  startTime: number;
  endTime: number;
  maxTickets: {
    standard: number;
    gold: number;
    premium: number;
    presidentiel: number;
  };
  image: string;
  status: "active" | "expired";
  createdAt: number;
}

export function useEvents() {
  const [events, setEvents] = useState<BakatiketEvent[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const eventsRef = ref(db, "events");
    // Filter by active status for the home page
    const activeEventsQuery = query(
      eventsRef, 
      orderByChild("status"), 
      equalTo("active")
    );

    const unsubscribe = onValue(activeEventsQuery, (snapshot) => {
      const data = snapshot.val();
      if (!data) {
        setEvents([]);
      } else {
        const eventList = Object.entries(data).map(([id, val]: [string, any]) => ({
          ...val,
          id,
        }));
        
        // Filter out expired by time as well, just in case Cloud Function hasn't run
        const now = Date.now();
        const validEvents = eventList.filter(e => e.endTime > now);
        
        setEvents(validEvents);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  return { events, loading };
}
