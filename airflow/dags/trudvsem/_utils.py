import httpx
import lxml.etree as et
import pendulum

def get_history(link: str, date: str):
    data = httpx.get(link).content

    parser = et.XMLPullParser(tag='dataversion')
    parser.feed(data)

    return [
        {
            'source': ver.findtext('source'),
            'created': ver.findtext('created')
        }
        for _,ver
        in parser.read_events()
        if pendulum.parse(ver.findtext('created')).format('YYYY-MM-DD') == date
    ]