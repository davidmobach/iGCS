/*
 *	Ivy, C interface
 *
 *	Copyright (C) 1997-2000
 *	Centre d'Études de la Navigation Aérienne
 *
 * 	Main loop handling around select
 *
 *	Authors: François-Régis Colin <fcolin@cena.dgac.fr>
 *		 Stéphane Chatty <chatty@cena.dgac.fr>
 *
 *	$Id: ivyloop.h 3243 2008-03-21 09:03:34Z bustico $
 * 
 *	Please refer to file version.h for the
 *	copyright notice regarding this software
 *
 */

#ifndef IVYLOOP_H
#define IVYLOOP_H

#ifdef __cplusplus
extern "C" {
#endif

#include "ivychannel.h"

/* general Handle */

#define ANYPORT	0

/*
Boucle principale d'IVY baseé sur un select
les fonctions hook et unhook encradre le select 
de la maniere suivante:

	BeforeSelect est appeler avant l'appel system select
	AfterSelect est appeler avent l'appel system select
	ces function peuvent utilisées pour depose un verrou dans le cas 
	d'utilisation de la mainloop Ivy dans une thread separe
	
	BeforeSelect ==> on libere l'acces avant la mise en attente sur le select
	AfterSelect == > on verrouille l'acces en sortie du select 

	!!!! Attention donc l'appel des callbacks ivy se fait avec l'acces verrouille !
*/

extern void IvyMainLoop(void);

typedef void ( *IvyHookPtr) ( void *data );

extern void IvyChannelAddWritableEvent(Channel channel);
extern void IvyChannelClearWritableEvent(Channel channel);
extern void IvySetBeforeSelectHook(IvyHookPtr before, void *data );
extern void IvySetAfterSelectHook(IvyHookPtr after, void *data );

#ifdef __cplusplus
}
#endif

#endif

