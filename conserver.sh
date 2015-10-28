#!/bin/bash
# ---------------------------------------------
# A stupid tool for quick connection by console
# Usage: ./conserver.sh your-hostname
# ---------------------------------------------

HOST=$1

case ${HOST} in

	*bne*) CONSERVER="conserver-01.app.eng.bne.redhat.com";;

	*rdu*) CONSERVER="conserver-01.app.eng.rdu.redhat.com";;

	*bos*) CONSERVER="console.eng.bos.redhat.com";;

	*brq*) CONSERVER="conserver.englab.brq.redhat.com";;

	*nay*) CONSERVER="console.lab.eng.nay.redhat.com";;

	*)     CONSERVER="conserver-01.eng.bos.redhat.com";;
esac

sudo console -l liwan -M ${CONSERVER} ${HOST}
