import { Entity, Column , PrimaryGeneratedColumn ,ManyToOne , JoinColumn } from "typeorm";
import { User } from "src/users/users.entity";

@Entity ()
export class Message {
    @PrimaryGeneratedColumn()
    id : string ;
    @Column()
    conversationId : string;
    
    @Column()
    senderId : string ;
    @ManyToOne (()=> User)
    @JoinColumn({name: 'senderId'})
    sender : User ;

    @Column()
    content : string;
    
    @Column()
    timestamp : Date ;
    @Column ({ default: false})
    isRead : boolean;

}